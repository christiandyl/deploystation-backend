module ApiDeploy
  class ContainerCreateWorker
    include Sidekiq::Worker

    def perform(container_id, opts)
      begin
        container = Container.find(container_id)
        container.create_docker_container(opts)
      
        Pusher.trigger "container-#{container_id}", "container_has_created", container.to_api(:public)
      rescue => e
        Pusher.trigger "container-#{container_id}", "container_creation_error", {}
      end
    end

  end
end