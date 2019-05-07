class CreateGolfRetailers < ActiveRecord::Migration[5.2]
  def change
    create_table :golf_retailers do |t|
      t.string :name
      t.string :mail_address_1
      t.string :mail_address_2
      t.string :city
      t.string :state
      t.string :country
      t.string :zip
      t.string :phone
      t.boolean :fitter
      t.boolean :retailer
      t.decimal :longitude
      t.decimal :latitude

      t.timestamps
    end
  end
end
