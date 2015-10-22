module ApiConverter

  def self.included(o)
    o.extend(ClassMethods)
  end

  module ClassMethods

    def attr_api public, **opts
      attrs = {
          :public  => public,
          :private => public + (opts[:private] || [])
      }

      send :define_method, :to_api do |flavor|
        hs = {}
        attrs[flavor].each do |a|
          attr = send(a)
          if attr.is_a? ActiveRecord::Base
            attr = attr.to_api(flavor)
          elsif attr.is_a? ActiveRecord::Relation
            attr = attr.map { |m| m.to_api(:public) }
          end
          hs[a] = attr
        end

        return hs
      end
    end

  end

end