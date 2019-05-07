class CreateCoords < ActiveRecord::Migration[5.2]
  def change
    create_table :coords do |t|
      t.string :city
      t.string :state
      t.decimal :latitude
      t.decimal :longitude
      t.integer :rank
      t.integer :population

      t.timestamps
    end
  end
end
