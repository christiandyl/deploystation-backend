require 'faker'

FactoryGirl.define do

  factory :connect_login do
    user
    email { Faker::Internet.email.sub('@', "_#{Time.now.to_i}@") }
    password { Faker::Internet.password }
  end

  factory :user do
    email { Faker::Internet.email.sub('@', "_#{Time.now.to_i}@") }

    after(:create) do |u|
      create :connect_login, :user => u
    end
  end

end