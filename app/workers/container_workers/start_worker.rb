module ContainerWorkers
  class StartWorker
    include Sidekiq::Worker

    sidekiq_options queue: 'critical', :retry => false, :backtrace => true, :unique => :while_executing

    def perform(container_id)
      begin
        container = Container.find(container_id)
        container = Container.class_for(container.game.sname).find(container_id)
        
        if container.status == Container::STATUS_ONLINE
          Pusher.trigger "container-#{container_id}", "start", { success: true }
          return true
        end
        
        container.start(true)
        
        Rails.logger.debug "Checking container #{container.id} status..."
        done = false
        sleep 5
        80.times do
          progress = container.starting_progress
          if (done = (progress[:progress] == 1.0))
            Rails.logger.debug "Container #{container_id} started successfully"
            Pusher.trigger "container-#{container_id}", "start", { success: true }
            notification = Notification.create user_id: container.user_id, alert: "Server started"
            done = true
            break
          else
            Rails.logger.debug "Container start status is #{progress.to_s}"
            sleep 3
          end
        end
        
        raise "Container #{container.id} didn't start" unless done
      rescue => e
        Pusher.trigger "container-#{container_id}", "start", { success: false }
        raise e
      end
    end

  end
end