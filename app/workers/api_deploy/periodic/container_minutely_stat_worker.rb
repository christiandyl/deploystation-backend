module ApiDeploy
  module Periodic
    class ContainerMinutelyStatWorker
      include Sidekiq::Worker

      sidekiq_options :unique => :while_executing, :queue => 'background'

      def perform(limit, offset)
        Container.all.each do |c|
          players = c.players_on_server.split("/").first.to_i rescue 0
          
          if players > 0
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
end