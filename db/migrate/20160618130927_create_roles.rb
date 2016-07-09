class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.belongs_to :user
      t.string :name
      t.timestamps
    end
  end
end
