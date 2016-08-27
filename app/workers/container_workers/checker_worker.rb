module ContainerWorkers
  class CheckerWorker
    include Sidekiq::Worker

    def perform
      byebug

      time_now = Time.now
      
      args = { now: time_now, suspended: Container::STATUS_SUSPENDED }
      ls = Container.where("(active_until > :now && status != :suspended", args)
      ls.each { c.suspend }
    end

  end
end