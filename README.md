# README

Alright, this project is used to convert scraped/imported businesses to mailable data points. It's a Rails project, but only because rails has some great tools usable to scrape with built-in.

Techniaclly, the scraping tools could be extracted to a POR project, but this was the quickest way to get to work.

Any code you may need to look at that is relevant to this project/scraping for AM is located in `/app/services/*.rb` and (`/app/models/kite_retailer.rb` || `/app/models/golf_retailer.rb`

Steps to get going:

1. Have Ruby 2.5.3 installed
   1. If using a mac, use [Homebrew](https://brew.sh/)
   2. Install [Rbenv](https://github.com/rbenv/rbenv) (a Ruby environement manager) - instructions in the linked Repo.
   3. Once Rbenv is instaled, run `$ rbenv install 2.5.3` which will install Ruby 2.5.3. Restart your comp here.
   4. Lastly, install the Ruby package manager, Bundler with `$ gem install bundler`
2. Clone and `cd` into this Repo
3. `$ bundle install`
4. I'm 93% sure you don't need to bother installing any of the JS/node_modules so unless shit is broken, ignore them. If it is broken, just run `yarn install`
5. Lastly, hook up the database. Right now it is configured to use Postgres (the superior database - don't @ me) but if you'd rather, you can change it to use MySQL or whatever you like. If you want to do that, just google 'Changing Ruby Database from Postgres to MySQL' - should be plenty of tutorials there.
   1. If you have Postgres installed on your system (there's a Brew package for it if you don't), then just run `rails db:setup` to install the database.
   2. If you need to configure database users/passwords, you can do so in `/config/database.yml`
6. Once you've done the above steps, you should have this project and it's dependancies installed on your system. You can now access the Rails Console where you will be doing everything else. To access the rails console, from the project's root directory, run `$ rails c`

Awesome. At this point, you should have Ruby installed, the rails project on your comp locally and all of its dependancies installed. Lets do some stuff. Open up the Rails Console with your `$ rails c` command.

## Adding Businesses

When I started, I had planned on sourcing the businesses from two sources:

1. Sporting Goods Equipment Manufacturers websites via "Find a retailer"
2. Google Maps Places API via - Search Nearby "[golf shop || kiteboarding store || surfing shop etc] + Coordinates of 1000 largest cities in the US or other countries"

I started building out a scraper with Watir then Pupeteer to start on the first step, I found that many Manufacturers websites exposed a public API containing all of their retails to Google Maps or whatever mapping service they were using on their site.

For example:

- https://ping.com/find-retailers?lat=33.86&lng=-116.52 is the PING Golf retailer finder.
- When you move the map around, under your browser's Developer Tools (Network Section on Firefox), if you filter by request type, you can see that everytime you move the map, there is an XHR request fired off to: https://ping.com/FindRetailerAPI?Lat=33.759587368772394&Long=-115.58616210937497&Radius=25
- With a bit of manipulation, we adjust that query to instead center on the middle of the US (and europe later) with Lat=39.833333 and Long=-98.583333 and change our radius from 25 miles to say 2,000 miles (roughly an area encompasing the entire continentl USA + parts of canada where people live).
- That query would look like: https://ping.com/FindRetailerAPI?Lat=39.833333&Long=Long=-98.583333&Radius=2000
- Boom! That query should result in a JSON file with all PING retails in the USA. Exactly what we need.
- This pattern of unsecured API's on manufacturers website works on around 1/3 manufactureres. It's also how I got the list of Kiteboard shops and I suspect it could be used for retailes across industries.

Using the json files I found, I just added them to the database with a dirty `retailers = JSON.parse()...` into each model (kite_retailer, golf_retailer). Explaining how to add models and import stuff is beyong the scope of this tutorial, but keywords to good should be "Generate Rails Models" and "Importing Json to Rails Models/Database"

## Processing the Data - Part 1 - Google Places

Step one of having something of value to work with was getting the businesses websites. All code used is found in `app/services/get_place_details.rb`. This assumes you've got a database table and Rails Model of the object (store type) you want to process:

1. Open up rails console (`$ rails c`)
2. Assuming you have a databse table of businesses collected (either scraped or pulled via open retailer-finder api) and that database has the business name, lat and longitude (which it should if you got it via a retailer-finder api) it will work.
3. The function we're calling is `GetPlaceDetails::GetGooglePlaceId.call(retailer_type, start_number, end_number)` where retailertype is a string and matches the model name (example, 'golf' or 'kite'), start_number is the database id number that you want to start the query on, (ex 1001) and end_number is the database id number that you want to end on (ex 1003).
   1. Here's an example: `GetPlaceDetails::GetGooglePlaceId.call('golf', 1003, 1023)`
   2. This will take all businesses with database id's between and including 1003 and 1023 (so 24 records) and will find them using the Google Places API, then update the database record to include their google places ID (which is required in the next part to get their website and mailing address)
   3. website and other business details.
4. I added the start & end numbers so you could restrict the number of api calls to google (I think you get a free 5,000/month)
5. There you go. This function takes your database record, queries the google places api and returns an updated record that contains the google places ID number which you can then use in the next step.

## Processing the Data - Part 2 - Getting the Website and Mailing Address

Now that our database records have a google places ID number, we can query the _Google Places Details_ api using the google places ID.

The function that handles this is in `app/services/get_place_details.rb` under the `GetPlaceDetails::GetGoogleDetails` class with the `self.call` function.

1. Open rails console with `$ rails c`
2. Using the record range you used in the last section (the ones that now have a google places ID number), run the following: `GetPlaceDetails::GetGoogleDetails.call('golf', 1003, 1023)`
3. This will take each record, and using it's google places ID number, query the google places api and get the businesses website and mailaing address. It will then update the record with these new data pieces.
4. Done. Your database should now contain records that have both a google places ID number, as well as a website and mailing address. In the next step we will take their website and (hopefully) convert it into an email address.

## Processing the Data - Part 3 - Getting the Email Addresses

This one is contreversial. So far of the email addresses it has returned, there has been a soft bounce rate of ~8% so perhaps just using Amazon Turk would make more sense. Anyhow, here's a brief overview of the function that takes the database items that have a website, tries a few combinations agains the MailGun API and returns an email address if one of them matches.

We will be using the `GetPlaceDetails::FindEmail` class found in `app/services/get_place_details.rb` to do this.

1. Open Rails console `$ rails c`
2. Using the record range from the previous step, of businesses records in our database that have a website, we can run the following: `GetPlaceDetails::FindEmail.call('golf', 1003, 1023)`
3. Are you seeing the patern yet? All top level (call) functions use the same schema of `(retailer_type, db_id_start, db_id_end)` to make the queries.
4. Give this one time, it's a bit slow and I didn't have the time to convert it to a concurant API call so such is life. Once it finishes, it should have populated the database records with either an email address, or, a "not_found" flag.
5. Our next and last step is a quick and dirty function that should export the records to a csv file.

## Processing the Data - Part 4 - Exporting the Details.

Our last function is found in the class `GetPlaceDetails::SaveToCSV` in the `app/services/get_place_details.rb` file.

1. Last step is simple: `GetPlaceDetails::SaveToCSV.call('golf', 1003, 1023)` which will export the records to a csv file (with headers) the the project folder root that can then be imported into active campaign.
2. That's all for now, folks!

## Processing the Data - Bonus - Extra functions

Just a heads up, under `app/models/golf_retailer.rb` there are a few bonus functions in there you can use to manipulate the data before exporting it as a CSV. A big one is to flag any business that has a shared website as a duplicate.
