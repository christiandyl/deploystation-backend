module ContainerWorkers
  module Periodic
    class ChargeCreditsWorker
      include Sidekiq::Worker

      LAUNCH_EVERY = 1.hour.freeze

      sidekiq_options :unique => :while_executing, :queue => 'background'

      def perform(**opts)
        limit  = opts[:limit]
        offset = opts[:offset]

        list = limit && offset ? Container.active.limit(limit).offset(offset) : Container.active
        list.each { |c| c.charge_credits }
      end
    end
  end
end
