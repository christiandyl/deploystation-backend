module ApiDeploy
  class ContainerDestroyWorker
    include Sidekiq::Worker

    def perform(container_id)
      begin
        container = Container.find(container_id)
        container = Container.class_for(container.game.sname).find(container_id)
        container.destroy_container(true)
        sleep 1
      
        Pusher.trigger "container-#{container_id}", "destroy", { success: true }
      rescue => e
        Pusher.trigger "container-#{container_id}", "destroy", { success: false }
        raise e
      end
    end

  end
end