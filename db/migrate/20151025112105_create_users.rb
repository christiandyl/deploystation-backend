class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :full_name
      t.text   :avatar_url
      t.timestamps null: false
    end
  end
end