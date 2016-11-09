ActiveAdmin.register Plan do
  permit_params :name, :max_players, :ram, :storage, :storage_type, :price, :price_per_hour

  actions :all, :except => [:destroy]

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
    column :price_per_hour
    
    actions
  end

  form do |f|
    inputs 'General' do
      input :host
      input :game, as: :select, collection: Game.available.map { |g| [g.name, g.id] }
      input :name
      input :price_per_hour
    end
    inputs 'Plan settings' do
      input :max_players
      input :ram, as: :select, collection: 21.times.collect { |n| 256 * (n+1) }
      input :storage, as: :select, collection: 11.times.collect { |n| 1024 * (n+1) }
      input :storage_type, as: :select, collection: ['ssd', 'hdd']
    end
    actions
  end
end