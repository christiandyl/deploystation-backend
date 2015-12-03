games = [
  { name: 'Minecraft' },
  { name: 'Minecraft pocket edition' },
  { name: 'Counter-strike go' },
  { name: 'Battlefield 4' },
  { name: 'Battlefield hard line' },
  { name: '7 days to die' },
  { name: 'DayZ Standalone' }
]

if Rails.env.production? # Production seeds
  plans = [
    {
      :game         => 'Minecraft',
      :host         => 'production',
      :name         => 'starter',
      :max_players  => 2,
      :ram          => 256,
      :storage      => 1024,
      :storage_type => 'ssd',
      :price        => "3"
    },
    {
      :game         => 'Minecraft',
      :host         => 'production',
      :name         => 'lite',
      :max_players  => 7,
      :ram          => 384,
      :storage      => 1024,
      :storage_type => 'ssd',
      :price        => "5"
    },
    {
      :game         => 'Minecraft',
      :host         => 'production',
      :name         => 'medium',
      :max_players  => 12,
      :ram          => 512,
      :storage      => 1024,
      :storage_type => 'ssd',
      :price        => "8"
    }
  ]
  
  hosts = [{ name: 'production', ip: '195.69.187.71', domain: '195.69.187.71', location: 'Kharkiv' }]
elsif Rails.env.staging? # Staging seeds
  plans = [
   {
     :game         => 'Minecraft',
     :host         => 'staging',
     :name         => 'starter',
     :max_players  => 2,
     :ram          => 256,
     :storage      => 1024,
     :storage_type => 'ssd',
     :price        => "3",
   },
   {
     :game         => 'Minecraft',
     :host         => 'staging',
     :name         => 'lite',
     :max_players  => 7,
     :ram          => 384,
     :storage      => 1024,
     :storage_type => 'ssd',
     :price        => "5",
   },
   {
     :game         => 'Minecraft',
     :host         => 'staging',
     :name         => 'medium',
     :max_players  => 12,
     :ram          => 512,
     :storage      => 1024,
     :storage_type => 'ssd',
     :price        => "8"
   }
 ]
 
 hosts = [{ name: 'staging', ip: '195.69.187.71', domain: '195.69.187.71', location: 'Kharkiv' }]
else # Development and Testing seeds
  plans = [
   {
     :game         => 'Minecraft',
     :host         => 'localhost',
     :name         => 'starter',
     :max_players  => 2,
     :ram          => 256,
     :storage      => 1024,
     :storage_type => 'ssd'
   },
   {
     :game         => 'Minecraft',
     :host         => 'localhost',
     :name         => 'lite',
     :max_players  => 7,
     :ram          => 384,
     :storage      => 1024,
     :storage_type => 'ssd'
   }
 ]

 hosts = [{ name: 'localhost', ip: '127.0.0.1', domain: 'localhost', location: 'Localhost' }]
#  plans = [
#   {
#     :game         => 'Minecraft',
#     :host         => 'kharkiv_prod_test',
#     :name         => 'starter',
#     :max_players  => 2,
#     :ram          => 256,
#     :storage      => 1024,
#     :storage_type => 'ssd'
#   },
#   {
#     :game         => 'Minecraft',
#     :host         => 'kharkiv_prod_test',
#     :name         => 'lite',
#     :max_players  => 7,
#     :ram          => 384,
#     :storage      => 1024,
#     :storage_type => 'ssd'
#   }
# ]
#
#  hosts = [{ name: 'kharkiv_prod_test', ip: '212.3.116.101', domain: '212.3.116.101', location: 'Kharkiv' }]
end

Game.delete_all
games.each do |attrs|
  Game.create(attrs)
end
puts 'Games table is ready'

Host.delete_all
hosts.each do |attrs|
  Host.create(attrs)
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