class GolfRetailer < ApplicationRecord
  # attr_accessor :website


  def self.extract_hostnames
    # puts self.website
    current_website = self.website
    new_website = Addressable::URI.parse(current_website).host.split('.', 2)[1]
    self.update(website: new_website)
  end

  def self.flag_duplicate_domains
    dupliacte_domains = self.select([:website]).group(:website).having("count(website) > 1").count.keys
    self.where(website: dupliacte_domains).each do |retailer|
      retailer.update(duplicate_domain: true)
    end
  end

  def self.find_duplicates
    # duplicate_retailers = self.select([:name]).group(:name).having("count(website) > 1").count.keys
    duplicate_retailers = self.select([:name]).group(:name).having("count(website) > 1").all.count
  end

end
