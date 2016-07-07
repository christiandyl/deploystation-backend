require 'rails_helper'

describe 'Container checker', :type => :request do
  
  before :all do
    users = []
    3.times do
      users << create(:user)
    end
    plans = Plan.all

    5.times do
      model = Container.new.tap do |m|
        m.user_id      = users.sample.id
        m.plan_id      = plans.sample.id
        m.host_id      = plans.sample.host_id
        m.port         = "25565"
        m.name         = Faker::Lorem.word
        m.status       = Container::STATUS_ONLINE
        m.is_private   = [true,false].sample
        m.active_until = (-0.5).days.from_now
        m.is_paid      = false
      end
      model.save!
    end
  end
  
  it 'Run container checker' do
    ContainerWorkers::CheckerWorker.perform_async
  end

end