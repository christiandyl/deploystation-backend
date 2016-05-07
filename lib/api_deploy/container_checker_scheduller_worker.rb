module ApiDeploy
  class ContainerCheckerSchedullerWorker
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    recurrence { minutely.second_of_minute(9, 19, 29, 39, 49, 59) }

    def perform
      ApiDeploy::ContainerCheckerWorker.perform_async(Container.count, 0)
    end
  end
end