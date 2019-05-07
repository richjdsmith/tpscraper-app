class AddAddedToAcToGolfRetailer < ActiveRecord::Migration[5.2]
  def change
    add_column :golf_retailers, :added_to_ac, :boolean, default: false, null: false
    add_column :golf_retailers, :sent_email, :boolean, default: false, null: false
  end
end
