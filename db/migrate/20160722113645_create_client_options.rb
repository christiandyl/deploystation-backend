class CreateClientOptions < ActiveRecord::Migration
  def change
    create_table :client_options, id: false, force: true do |t|
      t.string :key, null: false
      t.belongs_to :user
      t.string :platform
      t.string :vtype
      t.string :value
      t.timestamps
    end

    execute "ALTER TABLE client_options ADD PRIMARY KEY (key, user_id);"
    # add_index :client_options, [:key], name: :index_client_options_on_key, unique: true, using: :btree
  end
end
