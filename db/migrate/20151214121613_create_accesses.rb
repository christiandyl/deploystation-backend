class CreateAccesses < ActiveRecord::Migration
  def change
    create_table :accesses do |t|
      t.integer :container_id
      t.integer :user_id
    end
  end
end
