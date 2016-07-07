module Backend
  class Logger
    class << self
      def debug(message, **opts)
        type = opts[:type] || 'default'

        Rails.logger.debug(message)
      end

      def error(message, **opts)
        type = opts[:type] || 'default'

        Rails.logger.debug(message)
      end

      def info(message, **opts)
        type = opts[:type] || 'default'

        Rails.logger.debug(message)
      end
    end
  end
end
