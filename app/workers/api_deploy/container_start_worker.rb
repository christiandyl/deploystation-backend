module ApiDeploy
  class ContainerStartWorker
    include Sidekiq::Worker

    def perform(container_id, opts)
      begin
        container = Container.find(container_id)
        container = Container.class_for(container.game.name).find(container_id)
        container.start(opts, true)
        
        Rails.logger.debug "Checking container #{container.id} status..."
        done = false
        sleep 3
        20.times do
          progress = container.starting_progress
          if (done = (progress[:progress] == 1.0))
            Rails.logger.debug "Container #{container_id} started successfully"
            Pusher.trigger "container-#{container_id}", "start", { success: true }
            break
          end
          Rails.logger.debug "Container start status is #{progress.to_s}"
          sleep 3
        end
        
        raise "Container #{container.id} didn't start" unless done
      rescue => e
        Pusher.trigger "container-#{container_id}", "start", { success: false }
        raise e
      end
    end

  end
end