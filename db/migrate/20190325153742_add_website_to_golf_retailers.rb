class AddWebsiteToGolfRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :golf_retailers, :website, :string
    add_column :golf_retailers, :formatted_address, :string
    add_column :golf_retailers, :google_places_name, :string
  end
end
