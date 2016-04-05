class AddPayedToContainers < ActiveRecord::Migration
  def change
    add_column :containers, :is_paid, :boolean, null: false
  end
end
