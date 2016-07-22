require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  handler do |job, time|
    puts "Running #{job}, at #{time}"
    
    case job
      when 'players_online.job'
        online_servers = Container.online.count
        puts "There are #{online_servers.to_s} online servers"
    
        if online_servers > 0
          limit = 100

          x = (online_servers / limit) + 1
    
          x.times do |i|        
            offset = i * limit
        
            puts "Requesting check with limit: #{limit.to_s} and offset: #{offset.to_s}"
            ContainerWorkers::Periodic::PlayersOnlineWorker.perform_async(limit, offset)
          end
        end
      when 'minutly_stat.job'
        ContainerWorkers::Periodic::MinutelyStatWorker.perform_async(500, 0)
      when 'daily_stat.job'
        ContainerWorkers::Periodic::DailyStatWorker.perform_async(500, 0)
        ContainerWorkers::Periodic::ChargeCreditsWorker.permorm_async
    end
  end

  time = Rails.env.production? ? 20 : 40
  every(time.seconds, 'players_online.job')

  if Rails.env.production?
    every(10.minute, 'minutly_stat.job')
    every(1.day, 'daily_stat.job', :at => '00:00')
  end
end
