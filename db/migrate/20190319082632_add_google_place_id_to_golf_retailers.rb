class AddGooglePlaceIdToGolfRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :golf_retailers, :place_id, :string
  end
end
