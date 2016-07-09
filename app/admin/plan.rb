ActiveAdmin.register Plan do
  permit_params :name, :max_players, :ram, :storage, :storage_type, :price

  index do
    column :id
    column :name
    
    column "Game" do |p|
      link_to p.game.name, admin_game_path(p.game)
    end
    
    column "Host" do |p|
      link_to p.host.location, admin_host_path(p.host)
    end
    
    column :max_players
    column :ram
    column :price
    
    actions
  end
end
