module ApiBack
  class ContainerCheckerWorker
    include Sidekiq::Worker

    def perform
      byebug

      time_now = Time.now
      
      args = { now: time_now, suspended: ApiDeploy::Container::STATUS_SUSPENDED }
      ls = ApiDeploy::Container.where("(active_until > :now && status != :suspended", args)
      ls.each { c.suspend }
    end

  end
end