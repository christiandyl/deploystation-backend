class CreateHosts < ActiveRecord::Migration
  def change
    create_table :hosts do |t|
      t.string  :name
      t.integer :ip
      t.string  :domain
      t.string  :location
      t.timestamps null: false
    end
  end
end
