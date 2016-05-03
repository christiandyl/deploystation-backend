module ApiDeploy
  class ContainerCheckerSchedullerWorker
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    recurrence { hourly.minute_of_hour(0, 15, 30, 45) }

    def perform
      ApiDeploy::ContainerCheckerWorker.perform_async(Container.count,0)
    end
  end
end