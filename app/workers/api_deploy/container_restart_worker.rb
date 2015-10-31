module ApiDeploy
  class ContainerRestartWorker
    include Sidekiq::Worker

    def perform(container_id)
      begin
        container = Container.find(container_id)
        container.restart(true)
      
        Pusher.trigger "container-#{container_id}", "container_has_restarted", container.to_api(:public)
      rescue => e
        Pusher.trigger "container-#{container_id}", "container_restarting_error", {}
      end
    end

  end
end