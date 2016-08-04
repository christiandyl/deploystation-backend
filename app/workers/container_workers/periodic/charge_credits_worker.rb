module ContainerWorkers
  module Periodic
    class ChargeCreditsWorker
      include Sidekiq::Worker

      LAUNCH_EVERY = 1.hour.freeze

      sidekiq_options queue: 'background'

      def perform(limit=nil, offset=nil)
        # limit  = opts[:limit]
        # offset = opts[:offset]

        list = limit && offset ? Container.active.limit(limit).offset(offset) : Container.active
        list.each { |c| c.charge_credits }
      end
    end
  end
end
