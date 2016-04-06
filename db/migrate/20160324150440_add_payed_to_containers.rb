class AddPayedToContainers < ActiveRecord::Migration
  def up
    add_column :containers, :is_paid, :boolean
    change_column_null :containers, :is_paid, true
  end

  def down
    remove_column :containers, :is_paid, :boolean
  end  
end
