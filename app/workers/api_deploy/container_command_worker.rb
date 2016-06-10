module ApiDeploy
  class ContainerCommandWorker
    include Sidekiq::Worker

    sidekiq_options queue: 'critical', :retry => false, :backtrace => true

    def perform(container_id, command_name, command_args)
      begin
        container = Container.find(container_id)
        container = Container.class_for(container.game.sname).find(container_id)

        output = container.command(command_name, command_args, true)
        
        Pusher.trigger "container-#{container_id}", "command", { success: true, result: output }
      rescue => e
        Pusher.trigger "container-#{container_id}", "command", { success: false, result: output }
        raise e
      end
    end

  end
end