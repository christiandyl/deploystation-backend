class CreateContainers < ActiveRecord::Migration
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    
    create_table :containers do |t|
      t.string   :docker_id
      t.integer  :user_id
      t.integer  :plan_id
      t.integer  :host_id
      t.string   :port
      t.string   :name
      t.string   :status
      t.boolean  :is_private, null: false
      t.datetime :active_until
      t.hstore   :server_config
      t.timestamps null: false
    end
  end
end
