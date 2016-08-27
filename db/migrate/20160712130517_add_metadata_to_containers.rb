class AddMetadataToContainers < ActiveRecord::Migration
  def change
    add_column :containers, :metadata, :hstore
    remove_column :containers, :is_paid, :boolean
  end
end
