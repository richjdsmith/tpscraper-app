class AddSourceToKiteRetailer < ActiveRecord::Migration[5.2]
  def change
    add_column :kite_retailers, :source_brand, :string
    add_column :kite_retailers, :source_url, :string
  end
end
