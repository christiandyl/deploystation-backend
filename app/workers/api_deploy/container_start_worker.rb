module ApiDeploy
  class ContainerStartWorker
    include Sidekiq::Worker

    def perform(container_id, opts)
      begin
        container = Container.find(container_id)
        container.start(opts, true)
      
        Pusher.trigger "container-#{container_id}", "container_has_started", container.to_api(:public)
      rescue => e
        Pusher.trigger "container-#{container_id}", "container_starting_error", {}
      end
    end

  end
end