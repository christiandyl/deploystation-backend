require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  handler do |job, time|
    puts "Running #{job}, at #{time}"
    
    case job
      when 'players_online.job'
        Container.periodic_worker(:players_online).perform_async_workers
      when 'minutly_stat.job'
        Container.periodic_worker(:minutely_stat).perform_async(500, 0)
      when 'daily_stat.job'
        Container.periodic_worker(:daily_stat).perform_async(500, 0)
      when 'charge_credits.job'
        Container.periodic_worker(:charge_credits).perform_async
    end
  end

  # Players online
  time = Rails.env.production? ? 20 : 40
  every(time.seconds, 'players_online.job')

  # Credits charge
  every(Container.periodic_worker(:charge_credits)::LAUNCH_EVERY, 'charge_credits.job')

  # Stats workers
  # if Rails.env.production?
  #   every(10.minute, 'minutly_stat.job')
  #   every(1.day, 'daily_stat.job', :at => '00:00')
  # end
end
