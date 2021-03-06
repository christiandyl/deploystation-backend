features = [
  { lib: "awesome", icon: "tasks", text: "Track server in real time\nGet notifications about server" },
  { lib: "awesome", icon: "gear", text: "Run commands without console\nEdit your server configuration" },
  { lib: "awesome", icon: "users", text: "Invite 5 friends max to play\nShare your server with friends" }
].to_json

games = [
  { name: 'Minecraft', sname: 'minecraft', status: Game::STATUS_ENABLED, features: features, order: 1 },
  { name: 'Minecraft pocket edition', sname: 'minecraft_pe', status: Game::STATUS_ENABLED, features: features, order: 3 },
  { name: 'Counter-strike go', sname: 'counter_strike_go', status: Game::STATUS_ENABLED, features: features, order: 2 },
  { name: 'Battlefield 4', sname: 'battlefield_4', status: Game::STATUS_COMING_SOON, features: features, order: 4 },
  { name: 'Battlefield hard line', sname: 'battlefield_hl', status: Game::STATUS_COMING_SOON, features: features, order: 5 },
  { name: '7 days to die', sname: 'seven_days_to_die', status: Game::STATUS_ENABLED, features: features, order: 6 },
  { name: 'DayZ Standalone', sname: 'dayz_standalone', status: Game::STATUS_COMING_SOON, features: features, order: 7 }
]

if Rails.env.production? # Production seeds
  plans = [
    {
      :game         => 'Minecraft',
      :host         => 'europe_1',
      :name         => 'starter',
      :max_players  => 2,
      :ram          => 256,
      :storage      => 1024,
      :storage_type => 'ssd',
      :price        => "3",
      :price_per_hour => 0.01
    },
    {
      :game         => 'Minecraft',
      :host         => 'europe_1',
      :name         => 'lite',
      :max_players  => 7,
      :ram          => 384,
      :storage      => 1024,
      :storage_type => 'ssd',
      :price        => "5",
      :price_per_hour => 0.02
    },
    {
      :game         => 'Minecraft',
      :host         => 'europe_1',
      :name         => 'medium',
      :max_players  => 12,
      :ram          => 512,
      :storage      => 1024,
      :storage_type => 'ssd',
      :price        => "8",
      :price_per_hour => 0.03
    }
  ]
  
  hosts = [{ name: 'europe_1', ip: '195.69.187.74', domain: 'ua.deploystation.com', location: 'Kharkiv (Ukraine)', host_user: 'ubuntu', country_code: "ua" }]
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
     :price_per_hour => 0.01
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
     :price_per_hour => 0.02
   },
   {
     :game         => 'Minecraft',
     :host         => 'staging',
     :name         => 'medium',
     :max_players  => 12,
     :ram          => 512,
     :storage      => 1024,
     :storage_type => 'ssd',
     :price        => "8",
     :price_per_hour => 0.03
   }
 ]
 
 hosts = [{ name: 'staging', ip: '195.69.187.71', domain: '195.69.187.71', location: 'Kharkiv', host_user: 'ubuntu', country_code: "ua" }]
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
     :price_per_hour => 0.03
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
     :price_per_hour => 0.03
   },
   {
     :game         => 'Minecraft',
     :host         => 'beta',
     :name         => 'medium',
     :max_players  => 12,
     :ram          => 512,
     :storage      => 1024,
     :storage_type => 'ssd',
     :price        => "0",
     :price_per_hour => 0.03
   }
 ]
 
 hosts = [{ name: 'beta', ip: '195.69.187.74', domain: 'ua.deploystation.com', location: 'Ukraine', host_user: 'ubuntu', country_code: "ua" }]
else # Development and Testing seeds
  plans = [
   {
     :game         => 'Minecraft',
     :host         => 'localhost',
     :name         => 'starter',
     :max_players  => 2,
     :ram          => 256,
     :storage      => 1024,
     :storage_type => 'ssd',
     :price        => '5',
     :price_per_hour => 0.01
   },
   {
     :game         => 'Minecraft',
     :host         => 'localhost',
     :name         => 'lite',
     :max_players  => 7,
     :ram          => 384,
     :storage      => 1024,
     :storage_type => 'ssd',
     :price        => '10',
     :price_per_hour => 0.02
    },{
      :game         => '7 days to die',
      :host         => 'localhost',
      :name         => 'lite',
      :max_players  => 2,
      :ram          => 1024,
      :storage      => 1024,
      :storage_type => 'ssd',
      :price        => '15',
      :price_per_hour => 0.03
    },
    {
      :game         => 'Counter-strike go',
      :host         => 'localhost',
      :name         => 'starter',
      :max_players  => 16,
      :ram          => 512,
      :storage      => 1024,
      :storage_type => 'ssd',
      :price        => "5",
      :price_per_hour => 0.01
    },
    {
      :game         => 'Minecraft pocket edition',
      :host         => 'localhost',
      :name         => 'starter',
      :max_players  => 5,
      :ram          => 256,
      :storage      => 1024,
      :storage_type => 'ssd',
      :price        => "2",
      :price_per_hour => 0.02
    }
 ]

 hosts = [{ name: 'localhost', ip: '127.0.0.1', domain: 'localhost', location: 'Localhost', host_user: 'vagrant', country_code: "us" }]
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

Region.delete_all
region_eu = Region.create(name: 'Europe', location: 'france', status: Region::STATUS_ENABLED)
region_us = Region.create(name: 'USA', location: 'united states', status: Region::STATUS_ENABLED)

Game.delete_all
games.each do |attrs|
  Game.create(attrs)
end
puts 'Games table is ready'

Host.delete_all
hosts.each do |attrs|
  attrs[:region_id] = region_eu.id
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

SteamServerLoginToken.delete_all
# cs go
model = SteamServerLoginToken.create({
  :app_id  => 730,
  :token   => "D57CE64E91A2EB9942200110BE79C848",
  :in_use  => false
})
model = SteamServerLoginToken.create({
  :app_id  => 730,
  :token   => "2A4587B393F40ED045746E2F1AB0FC85",
  :in_use  => false
})
puts 'SteamServerLoginToken table is ready'

puts 'Done'