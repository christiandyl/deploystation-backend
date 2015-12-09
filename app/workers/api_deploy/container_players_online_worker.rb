module ApiDeploy
  class ContainerPlayersOnlineWorker
    include Sidekiq::Worker

    def perform(container_id)
      begin
        container = Container.find(container_id)
        container = Container.class_for(container.game.name).find(container_id)

        players_online = container.players_online(true)

        result = {
          :container      => container.to_api(:public),
          :players_online => players_online
        }
        Pusher.trigger "user-#{container.user.id}-containers", "players_online", result
      rescue => e
        raise e
      end
    end

  end
end