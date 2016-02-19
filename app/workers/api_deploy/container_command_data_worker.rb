module ApiDeploy
  class ContainerCommandDataWorker
    include Sidekiq::Worker

    def perform(container_id, command_id)
      begin
        container = Container.find(container_id)
        container = Container.class_for(container.game.name).find(container_id)

        output = container.command_data(command_id, true)
        
        Pusher.trigger "container-#{container_id}", "command_data", { success: true, result: output }
      rescue => e
        Pusher.trigger "container-#{container_id}", "command_data", { success: false, result: output }
        raise e
      end
    end

  end
end