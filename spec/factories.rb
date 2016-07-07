require 'faker'

FactoryGirl.define do

  factory :connect_login do
    user
    email { Faker::Internet.email.sub('@', "_#{Time.now.to_i}@") }
    password { Faker::Internet.password }
  end

  factory :user do
    email { Faker::Internet.email.sub('@', "_#{Time.now.to_i}@") }
    full_name { Faker::App.author }

    after(:create) do |u|
      create :connect_login, :user => u
    end
  end
  
  factory :host do
    name         { Faker::Lorem.word }
    ip           { Faker::Internet.public_ip_v4_address }
    domain       { Faker::Internet.domain_name }
    location     { Faker::Address.city }
    country_code { Faker::Address.country_code.downcase }
    
    host_user "ubuntu"
  end
  
  factory :game do
    name   { Faker::Lorem.word }
    sname  { Faker::Lorem.word }
    status { [Container::STATUS_ONLINE, Container::STATUS_OFFLINE].sample }
    features do
      list = []
      3.times do
        list << { lib: "awesome", icon: "gear", text: Faker::Hacker.say_something_smart }
      end
      list.to_json
    end
  end
  
  factory :plan do
    game
    host
    name { Faker::Lorem.word }
    max_players { (2..20).to_a.sample }
  end

end