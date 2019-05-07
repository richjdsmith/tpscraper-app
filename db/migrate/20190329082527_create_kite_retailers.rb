class CreateKiteRetailers < ActiveRecord::Migration[5.2]
  def change
    create_table :kite_retailers do |t|
      t.string :name
      t.string :mail_address_1
      t.string :mail_address_2
      t.string :city
      t.string :state
      t.string :country
      t.string :zip
      t.string :phone
      t.decimal :longitude
      t.decimal :latitude
      t.string :place_id
      t.string :website
      t.string :formatted_address
      t.string :google_places_name
      t.string :email
      t.boolean :duplicate_domain, null: false, default: false

      t.timestamps
    end
  end
end
