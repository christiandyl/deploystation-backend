class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.integer :user_id
      t.string :device_type
      t.string :push_token
      t.timestamps null: false
    end
  end
end
