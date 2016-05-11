module ApiDeploy
  module Periodic
    class ContainerDailyStatWorker
      include Sidekiq::Worker

      sidekiq_options unique: :all, queue: 'low'

      def perform(limit, offset)
        Container.all.each do |c|
          container = Container.class_for(c.game.sname).find(c.id)
          container.calculate_stats
        end
      end

    end
  end
end