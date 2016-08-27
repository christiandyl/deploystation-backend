class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.belongs_to :user
      t.integer :type_id
      t.float :amount
      t.hstore :metadata
      t.timestamps null: false
    end
  end
end
