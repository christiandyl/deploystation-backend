module ApiDeploy::Periodic
  class ContainerDailyStatWorker
    include Sidekiq::Worker

    sidekiq_options unique: :all, queue: 'low'

    def perform(limit, offset)
      Container.all.each do |c|
        stat = ContainerStatPlayers.new({
          :container_id   => c.id,
          :players_online => c.players_on_server
        })
        stat.save
      end
    end

  end
end