module ApiExtension
  extend ActiveSupport::Concern

  included do
    def to_api(**opts)
      layers = opts[:layers] || []

      unless layers.is_a? Array
        raise ArgumentError, 'Argument "layers" is not an array'
      end

      api_attributes(layers)
    end

    def self.to_api(**opts)
      layers = opts[:layers] || []
      paginate = opts[:paginate]

      unless layers.is_a? Array
        raise ArgumentError, 'Argument "layers" is not an array'
      end

      records = all
      records = records.paginate(paginate) unless paginate.nil?

      ls = records.map { |m| m.api_attributes(layers) }

      if paginate
        data = {
          list: ls,
          current_page: records.current_page,
          is_last_page: (records.total_pages == records.current_page)
        }
      else
        data = ls
      end

      data
    end
  end
end
