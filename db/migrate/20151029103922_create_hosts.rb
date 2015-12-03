class CreateHosts < ActiveRecord::Migration
  def change
    create_table :hosts do |t|
      t.string :name
      t.column :ip, :bigint
      t.string :domain
      t.string :location
      t.string :host_user
      t.timestamps null: false
    end
  end
end
