class CreateSteamServerLoginTokens < ActiveRecord::Migration
  def change
    create_table :steam_server_login_tokens do |t|
      t.integer :app_id
      t.string :token
      t.boolean :in_use, :default => false
      t.timestamps null: false
    end
  end
end
