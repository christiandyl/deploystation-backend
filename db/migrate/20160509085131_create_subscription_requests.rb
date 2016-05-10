class CreateSubscriptionRequests < ActiveRecord::Migration
  def change
    create_table :subscription_requests do |t|
      t.belongs_to :user
      t.belongs_to :container
      t.belongs_to :plan
      t.string :status
      t.text :comment
      t.timestamps null: false
    end
  end
end
