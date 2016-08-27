class AddPricePerHourToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :price_per_hour, :float
  end
end
