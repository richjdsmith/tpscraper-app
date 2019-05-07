# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_03_29_112514) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "coords", force: :cascade do |t|
    t.string "city"
    t.string "state"
    t.decimal "latitude"
    t.decimal "longitude"
    t.integer "rank"
    t.integer "population"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "golf_retailers", force: :cascade do |t|
    t.string "name"
    t.string "mail_address_1"
    t.string "mail_address_2"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "zip"
    t.string "phone"
    t.boolean "fitter"
    t.boolean "retailer"
    t.decimal "longitude"
    t.decimal "latitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "place_id"
    t.string "website"
    t.string "formatted_address"
    t.string "google_places_name"
    t.string "email"
    t.boolean "duplicate_domain"
    t.string "source_brand"
    t.string "source_url"
    t.boolean "added_to_ac", default: false, null: false
    t.boolean "sent_email", default: false, null: false
    t.index ["duplicate_domain"], name: "index_golf_retailers_on_duplicate_domain"
  end

  create_table "kite_retailers", force: :cascade do |t|
    t.string "name"
    t.string "mail_address_1"
    t.string "mail_address_2"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "zip"
    t.string "phone"
    t.decimal "longitude"
    t.decimal "latitude"
    t.string "place_id"
    t.string "website"
    t.string "formatted_address"
    t.string "google_places_name"
    t.string "email"
    t.boolean "duplicate_domain", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source_brand"
    t.string "source_url"
  end

end
