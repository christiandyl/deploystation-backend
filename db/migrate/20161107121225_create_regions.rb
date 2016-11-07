class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.string :name
      t.string :location
      t.string :status
      t.float :latitude
      t.float :longitude
      t.timestamps null: false
    end
  end
end
