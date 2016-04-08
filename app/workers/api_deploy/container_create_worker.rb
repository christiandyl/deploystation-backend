module ApiDeploy
  class ContainerCreateWorker
    include Sidekiq::Worker

    def perform(container_id, opts)
      begin
        container = Container.find(container_id)
        container = Container.class_for(container.game.sname).find(container_id)
        
        container.create_docker_container(opts)
        container.start
        
        Rails.logger.debug "Checking container #{container.id} status..."
        done = false
        sleep 3
        20.times do
          progress = container.starting_progress
          if (done = (progress[:progress] == 1.0))
            Rails.logger.debug "Container #{container_id} started successfully"
            Pusher.trigger "container-#{container_id}", "create", { success: true, result: progress }
            notification = Notification.create user_id: container.user_id, alert: "Server created"
            break
          end
          Rails.logger.debug "Container start status is #{progress.to_s}"
          Pusher.trigger "container-#{container_id}", "create", { success: true, result: progress }
          sleep 3
        end
        
        raise "Container #{container.id} didn't start" unless done
      rescue => e
        Pusher.trigger "container-#{container_id}", "create", { success: false, result: {} }
        raise e
      end
    end

  end
end