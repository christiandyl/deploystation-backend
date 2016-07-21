class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.belongs_to :user
      t.float :amount
      t.hstore :metadata
      t.timestamps null: false
    end
  end
end
