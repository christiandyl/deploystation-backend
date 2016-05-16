module ApiDeploy
  module Periodic
    class ContainerDailyStatWorker
      include Sidekiq::Worker

      sidekiq_options unique: :all, queue: 'low'

      def perform(limit, offset)
        total_time = 0
        Container.all.each do |c|
          container = Container.class_for(c.game.sname).find(c.id)
          stats = container.calculate_stats
          
          total_time += (stats[:total_gaming_time] || 0) rescue 0
        end
        total_minutes = total_time / 60
        ApiDeploy::Helper::slack_ping("Total gaming time today (#{Time.now.to_s}) is #{total_minutes.to_s} minutes")
      end

    end
  end
end