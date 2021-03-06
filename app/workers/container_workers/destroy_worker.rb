module ContainerWorkers
  class DestroyWorker
    include Sidekiq::Worker

    sidekiq_options queue: 'critical', :retry => false, :backtrace => true, :unique => :while_executing

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