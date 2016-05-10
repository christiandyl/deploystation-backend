module ApiDeploy::Periodic
  class ContainerDailyStatWorker
    include Sidekiq::Worker

    sidekiq_options unique: :all, queue: 'low'

    def perform(limit, offset)
      Container.all.each { |c| c.calculate_stats }
    end

  end
end