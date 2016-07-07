module DockerServices
  class Backup
  
    REPOSITORY = "mohamnag/s3-dir-backup"
  
    attr_accessor :container_id, :container
  
    def initialize attrs
      self.container_id = attrs[:container_id]
      if attrs[:container]
        self.container = attrs[:container]
        self.container_id = container.id
      end
    
      Rails.logger.debug "Backup initialized for container #{container_id}"
    end
  
    def create now = false
      unless now    
        ContainerWorkers::BackupWorker.perform_async(container_id, :create)
        return true
      end
      
      Rails.logger.debug "Requesting backup for container-#{container_id}"

      opts = docker_opts
      opts["Cmd"] = ["/opt/backup.sh"]

      container.host.use
      Docker::Container.get(s3_container_name).delete(:force => true) rescue nil

      Rails.logger.debug "Creating backup for container-#{container_id} with opts: #{opts.to_s}"

      dcontainer = Docker::Container.create(opts)
      dcontainer.start
      dcontainer.wait
      
      Rails.logger.debug "Creating backup for container-#{container_id} is done"
      
      return true
    end
  
    def restore_latest now = false
      unless now    
        ContainerWorkers::BackupWorker.perform_async(container_id, :restore_latest)
        return true
      end
      
      Rails.logger.debug "Requesting backup for container-#{container_id}"
      
      opts = docker_opts
      opts["Cmd"] = ["/opt/restore.sh"]
    
      container.host.use
      Docker::Container.get(s3_container_name).delete(:force => true) rescue nil
    
      Rails.logger.debug "Restoring backup for container-#{container_id} with opts: #{opts.to_s}"
    
      dcontainer = Docker::Container.create(opts)
      dcontainer.start
      dcontainer.wait
      
      Rails.logger.debug "Restoring backup for container-#{container_id} is done"
      
      return true
    end
  
    private

    def docker_opts
      {
        "name"         => s3_container_name,
        "Image"        => REPOSITORY,
        "Args"         => ["--rm"],
        "VolumesFrom"  => [container.docker_container_id],
        "Env"          => [
          "AWS_ACCESS_KEY_ID=#{Settings.aws.key}",
          "AWS_SECRET_ACCESS_KEY=#{Settings.aws.secret}",
          "BACKUP_S3_BUCKET=#{backup_path}",
          "AWS_DEFAULT_REGION=#{Settings.aws.s3.region}"
        ]
      }
    end
  
    def s3_container_name
      "backup-s3-#{container.docker_container_id}"
    end
  
    def backup_path
      @backup_path ||= "#{Settings.aws.s3.bucket_backups}/#{container.docker_container_id}"
    end
    
    def container
      @container ||= Container.find(container_id)
    end
  
  end
end