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

  factory :event do
    user
    status Event::STATUS_VISIBLE
    name { Faker::Lorem.characters(3..20) }
    description { Faker::Lorem.sentence }
  end

  factory :event_with_comments, :parent => :event do
    after(:create) do |m|
      create_list :comment, 70, :event => m
    end
  end
  
  factory :event_with_likes, :parent => :event do
    after(:create) do |m|
      create_list :comment, [*20..60].sample, :event => m
    end
  end

  factory :event_with_tags, :parent => :event do
    after(:create) do |m|
      create_list :tagging, [*1..3].sample, :event => m
    end
  end

  factory :comment do
    event
    user
    message { Faker::Lorem.sentence }
  end

  factory :like do
    event
    user
  end

  factory :tagging do
    event
    tag
  end

  factory :tag do
    name { Faker::Lorem.characters(3..20) }
  end

end