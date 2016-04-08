class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :email
      t.string  :full_name
      t.string  :s3_region
      t.string  :s3_bucket
      t.boolean :has_avatar, default: false
      t.timestamps null: false
    end
  end
end