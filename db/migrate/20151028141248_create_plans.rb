class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.integer :game_id
      t.integer :host_id
      t.string  :name
      t.integer :max_players
      t.integer :ram
      t.integer :storage
      t.string  :storage_type
      t.timestamps null: false
    end
  end
end
