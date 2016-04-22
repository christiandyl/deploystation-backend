module ApiDeploy
  class ContainerPlayersOnlineWorker
    include Sidekiq::Worker

    sidekiq_options unique: :all

    def perform(container_id)
      begin
        container = Container.find(container_id)
        container = Container.class_for(container.game.sname).find(container_id)

        players_online = container.players_online(true)

        result = {
          :success => true,
          :result  => players_online
        }
        Pusher.trigger "container-#{container_id}", "players_online", result
      rescue => e
        Pusher.trigger "container-#{container_id}", "players_online", { success: false }
        raise e
      end
    end

  end
end