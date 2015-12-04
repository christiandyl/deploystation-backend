class CreateContainers < ActiveRecord::Migration
  def change
    create_table :containers do |t|
      t.string   :docker_id
      t.integer  :user_id
      t.integer  :plan_id
      t.integer  :host_id
      t.string   :port
      t.string   :name
      t.string   :status
      t.datetime :active_until
      t.timestamps null: false
    end
  end
end
