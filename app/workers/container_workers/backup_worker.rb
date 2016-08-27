module ContainerWorkers
  class BackupWorker
    include Sidekiq::Worker

    def perform(container_id, action)
      begin
        container = Container.find(container_id)
        
        success = case action.to_sym
          when :create
            container.backup.create(true)
          when :restore_latest
            container.backup.restore_latest(true)
          else
            raise "Unknown backup action"
        end

      rescue => e
        raise e
      end
    end

  end
end