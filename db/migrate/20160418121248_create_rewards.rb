class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.integer :inviter_id
      t.integer :invited_id
      t.hstore  :referral_data
      t.timestamps null: false
    end
  end
end
