class AddEmailToGolfRetailer < ActiveRecord::Migration[5.2]
  def change
    add_column :golf_retailers, :email, :string
    add_column :golf_retailers, :duplicate_domain, :boolean
    add_index :golf_retailers, :duplicate_domain
  end
end
