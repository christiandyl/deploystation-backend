class CreateContainers < ActiveRecord::Migration
  def change
    create_table :containers do |t|
      t.string :docker_id
      t.string :user_id
      t.string :image
      t.string :host
      t.string :status
      t.timestamps null: false
    end
  end
end
