module ApiDeploy
  class ContainerDestroyWorker
    include Sidekiq::Worker

    def perform(container_id)
      begin
        container = Container.find(container_id)
        container.destroy_container(true)
      
        Pusher.trigger "container-#{container_id}", "container_has_deleted", {}
      rescue => e
        Pusher.trigger "container-#{container_id}", "container_deleting_error", {}
        raise e
      end
    end

  end
end