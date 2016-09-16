module DynamicValue
  extend ActiveSupport::Concern

  included do
    self.primary_key = 'key'
    validates :vtype, inclusion: { in: %w(number string hash list bool) }
  end

  def api_attributes(_layers)
    h = {
      key: key,
      value: value
    }

    h
  end

  def value
    case vtype
      when 'number'
        super.to_f
      when 'string'
        super
      when 'hash'
        JSON.parse(super)
      when 'list'
        JSON.parse(super)
      when 'bool'
        super == 'true'
      else
    end
  end

  def value=(val)
    case vtype
      when 'number'
        super(val.to_s)
      when 'string'
        super(val.to_s)
      when 'hash'
        super(val.to_json)
      when 'list'
        super(val.to_json)
      when 'bool'
        super(val.to_s)
      else
    end
  end
end
