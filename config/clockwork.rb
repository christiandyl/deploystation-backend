require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  handler do |job, time|
    puts "Running #{job}, at #{time}"
    ApiDeploy::Periodic::ContainerPlayersOnlineWorker.perform_async(ApiDeploy::Container.count, 0)
  end

  every(10.seconds, 'players_online.job')
end