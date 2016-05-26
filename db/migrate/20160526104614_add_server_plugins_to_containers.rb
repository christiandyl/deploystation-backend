class AddServerPluginsToContainers < ActiveRecord::Migration
  def change
    add_column :containers, :server_plugins, :hstore
  end
end
