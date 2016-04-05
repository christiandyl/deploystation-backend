class AddFeaturesToGames < ActiveRecord::Migration
  def change
    add_column :games, :features, :text
  end
end
