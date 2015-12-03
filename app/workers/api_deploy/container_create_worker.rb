module ApiDeploy
  class ContainerCreateWorker
    include Sidekiq::Worker

    def perform(container_id, opts)
      begin
        container = Container.find(container_id)
        container.create_docker_container(opts)
      
        data = {
          :success => true,
          :result  => container.to_api(:public)
        }
        Pusher.trigger "container-#{container_id}", "create", data
      rescue => e
        data = { :success => false }
        Pusher.trigger "container-#{container_id}", "create", data
        raise e
      end
    end

  end
end