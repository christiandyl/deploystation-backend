class AddOrderToGames < ActiveRecord::Migration
  def change
    add_column :games, :order, :integer
  end
end
