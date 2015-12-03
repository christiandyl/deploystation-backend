module ApiDeploy
  class ContainerStopWorker
    include Sidekiq::Worker

    def perform(container_id)
      begin
        container = Container.find(container_id)
        container.stop(true)
      
        Pusher.trigger "container-#{container_id}", "container_has_stopped", container.to_api(:public)
      rescue => e
        Pusher.trigger "container-#{container_id}", "container_stopping_error", {}
      end
    end

  end
end