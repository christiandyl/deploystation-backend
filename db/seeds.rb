games = [
  { name: 'Minecraft', sname: 'minecraft', status: Game::STATUS_ENABLED },
  { name: 'Minecraft pocket edition', sname: 'minecraft_pe', status: Game::STATUS_COMING_SOON },
  { name: 'Counter-strike go', sname: 'counter_strike_go', status: Game::STATUS_COMING_SOON },
  { name: 'Battlefield 4', sname: 'battlefield_4', status: Game::STATUS_COMING_SOON },
  { name: 'Battlefield hard line', sname: 'battlefield_hl', status: Game::STATUS_COMING_SOON },
  { name: '7 days to die', sname: '7_days_to_die', status: Game::STATUS_COMING_SOON },
  { name: 'DayZ Standalone', sname: 'dayz_standalone', status: Game::STATUS_COMING_SOON }
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
  
  hosts = [{ name: 'production', ip: '195.69.187.71', domain: '195.69.187.71', location: 'Kharkiv', host_user: 'ubuntu' }]
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
 
 hosts = [{ name: 'staging', ip: '195.69.187.71', domain: '195.69.187.71', location: 'Kharkiv', host_user: 'ubuntu' }]
elsif Rails.env.beta? # Beta seeds
  plans = [
   {
     :game         => 'Minecraft',
     :host         => 'beta',
     :name         => 'starter',
     :max_players  => 2,
     :ram          => 256,
     :storage      => 1024,
     :storage_type => 'ssd',
     :price        => "0",
   },
   {
     :game         => 'Minecraft',
     :host         => 'beta',
     :name         => 'lite',
     :max_players  => 7,
     :ram          => 384,
     :storage      => 1024,
     :storage_type => 'ssd',
     :price        => "0",
   },
   {
     :game         => 'Minecraft',
     :host         => 'beta',
     :name         => 'medium',
     :max_players  => 12,
     :ram          => 512,
     :storage      => 1024,
     :storage_type => 'ssd',
     :price        => "0"
   }
 ]
 
 hosts = [{ name: 'beta', ip: '195.69.187.71', domain: '195.69.187.71', location: 'Ukraine', host_user: 'ubuntu' }]
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

 hosts = [{ name: 'localhost', ip: '127.0.0.1', domain: 'localhost', location: 'Localhost', host_user: 'vagrant' }]
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