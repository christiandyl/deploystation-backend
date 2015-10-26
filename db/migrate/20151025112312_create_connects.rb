class CreateConnects < ActiveRecord::Migration
  def change
    create_table :connects do |t|
      t.integer :user_id, nil: false
      t.string :partner, nil: false
      t.string :partner_id, nil: false
      t.string :partner_auth_data
      t.datetime :partner_expire
      t.text :partner_data
      t.timestamps null: false
    end
  end
end
