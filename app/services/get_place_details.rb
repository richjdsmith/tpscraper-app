require 'fuzzystringmatch'

GOOGLE_API_KEY = '#######################'
MAILGUN_API_KEY = 'a54ac79c################44-680c8b5a'
# The fuck do you want.
module GetPlaceDetails
  # This class is for all methods pertaining to finding and updating the places google places ID
  class GetGooglePlaceId
    def self.call(retailer_type, start_number, end_number)
      retailers = get_array_of_retailers(retailer_type, start_number, end_number)
      update_retailers_place_id(retailers)
    end

    def self.get_array_of_retailers(retailer_type, number_to_fetch_start, number_to_fetch_end)
      puts 'In get_array_of_retailers'
      "#{retailer_type.capitalize}Retailer".constantize.where(id: number_to_fetch_start..number_to_fetch_end).where(place_id: [nil, false])
    end

    def self.update_retailers_place_id(retailers)
      puts "In update_retailers_place_id"
      jarow = FuzzyStringMatch::JaroWinkler.create(:native)
      retailers.each do |retailer|
        response = call_places_search_api(retailer)
        if response['status'] == 'OK' && jarow.getDistance(retailer.name, response['candidates'][0]['name']) > 0.3
          puts "retailer matched, updating."
          retailer.update(place_id: response['candidates'][0]['place_id'])
        end
        sleep(0.2)
      end
    end

    def self.call_places_search_api(retailer)
      base_url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?key=#{GOOGLE_API_KEY}"
      request_url = base_url + "&input=#{retailer.name}&inputtype=textquery&fields=name,place_id&locationbias=circle:500@#{retailer.latitude},#{retailer.longitude}"
      HTTParty.get(request_url).parsed_response
    end
  end

  # This class calls googles places details api and updates the database with 
  class GetGoogleDetails
    def self.call(retailer_type, number_to_fetch_start, number_to_fetch_end)
      retailers = get_array_of_retailers(retailer_type, number_to_fetch_start, number_to_fetch_end)
      updates_retailers_website(retailers)
    end

    def self.get_array_of_retailers(retailer_type, number_to_fetch_start, number_to_fetch_end)
      "#{retailer_type.capitalize}Retailer".constantize.where.not(place_id: nil).where(id: number_to_fetch_start..number_to_fetch_end)
    end

    def self.updates_retailers_website(retailers)
      retailers.each do |retailer|
        response = call_places_details_api(retailer)
        if response['status'] == 'OK'
          retailer.update(website: response['result']['website'], formatted_address: response['result']['formatted_address'], google_places_name: response['result']['name'])
        end
      end
    end

    def self.call_places_details_api(retailer)
      base_url = "https://maps.googleapis.com/maps/api/place/details/json?key=#{GOOGLE_API_KEY}"
      request_url = base_url + "&placeid=#{retailer.place_id}&fields=website,formatted_address,name"
      HTTParty.get(request_url).parsed_response
    end
  end

  class SaveToCSV
    def self.call(retailer_type,range_start,range_end)
      # retailers = "#{retailer_type.capitalize}Retailer".constantize.where.not(website: nil).where(id: range_start..range_end).select([:id, :name, :email, :google_places_name, :mail_address_1, :mail_address_2, :city, :state, :country, :zip, :phone, :retailer, :website, :formatted_address])
      retailers = "#{retailer_type.capitalize}Retailer".constantize.where.not(website: nil).where(id: range_start..range_end).select([:id, :name, :email, :mail_address_1, :city, :country, :zip, :website, :formatted_address])
      retailers_csv = retailers.to_csv
      File.open("#{retailer_type.downcase}-website-mailing-list.csv", "w") do |output_file|
        output_file.write(retailers_csv)
      end
    end
  end

  # This class calls Mailguns Email Validation Api.
  class FindEmail
    def self.call(retailer_type, start_number, end_number)
      retailers = get_array_of_retailers(retailer_type, start_number, end_number)
      update_retailers_email(retailers)
    end

    def self.get_array_of_retailers(retailer_type, number_to_fetch_start, number_to_fetch_end)
      "#{retailer_type.capitalize}Retailer".constantize.where.not(website: nil, duplicate_domain: true).where(id: number_to_fetch_start..number_to_fetch_end)
    end

    def self.update_retailers_email(retailers)
      retailers.each do |retailer|
        email_response = try_email_addresses(retailer)
        retailer.update(email: email_response)
      end
    end

    def self.try_email_addresses(retailer)
      hostname = extract_hostname(retailer.website)
      addresses_to_try = %w[contact info admin shop store hello]
      addresses_to_try.each do |add|
        email_address = add + '@' + hostname
        response = call_mailgun(email_address)
        return email_address if response['result'] == 'deliverable'
      end
      'not_found'
    end

    def self.extract_hostname(domain)
      Addressable::URI.parse(domain).host.split('.', 2)[1]
    end

    def self.call_mailgun(email_address)
      base_url = "https://api:#{MAILGUN_API_KEY}@api.mailgun.net/v4/address/validate?"
      request_url = base_url + "address=#{email_address}"
      HTTParty.get(request_url).parsed_response
    end
  end

end
