games = [
  { name: 'minecraft' }
]

hosts = []

plans = [
  {
    :game         => 'minecraft',
    :host         => 'localhost',
    :name         => 'starter',
    :max_players  => 2,
    :ram          => 256,
    :storage      => 1024,
    :storage_type => 'ssd'
  },
  {
    :game         => 'minecraft',
    :host         => 'localhost',
    :name         => 'lite',
    :max_players  => 7,
    :ram          => 384,
    :storage      => 1024,
    :storage_type => 'ssd'
  }
]

Game.delete_all
games.each do |attrs|
  Game.create(attrs)
end
puts 'Games table is ready'

Host.delete_all
if Rails.env.in? ['development', 'test']
  Host.create name: 'localhost', ip: '127.0.0.1', domain: 'localhost', location: 'Localhost'
else
  hosts.each do |attrs|
    Host.create(attrs)
  end
end
puts 'Hosts table is ready'

Plan.delete_all
plans.each do |attrs|
  game = Game.find_by_name(attrs[:game])
  host = Host.find_by_name(attrs[:host])
  
  attrs.delete(:game)
  attrs[:game_id] = game.id

  attrs.delete(:host)
  attrs[:host_id] = host.id

  Plan.create(attrs)
end
puts 'Plans table is ready'

puts 'Done'