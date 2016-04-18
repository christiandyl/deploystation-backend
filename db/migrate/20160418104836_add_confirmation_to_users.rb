class AddConfirmationToUsers < ActiveRecord::Migration
  def up
    add_column :users, :confirmation, :boolean
    change_column_null :users, :confirmation, true
    change_column :users, :confirmation, :boolean, :default => false
  end

  def down
    remove_column :users, :confirmation, :boolean
  end  
end
