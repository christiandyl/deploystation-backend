module ApiDeploy
  module Periodic
    class ContainerDailyStatWorker
      include Sidekiq::Worker

      sidekiq_options unique: :all, queue: 'low'

      def perform(limit, offset)
        Container.all.each do |c|
          players = c.players_on_server.split("/").first rescue 0
          
          stat = ContainerStatPlayers.new({
            :container_id   => c.id,
            :players_online => players
          })
          stat.save
        end
      end
    end
  end
end