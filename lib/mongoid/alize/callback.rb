module Mongoid
  module Alize
    class Callback

      attr_accessor :fields

      attr_accessor :klass
      attr_accessor :relation
      attr_accessor :reflect

      attr_accessor :inverse_klass
      attr_accessor :inverse_relation

      def initialize(_klass, _relation, _fields)
        self.klass = _klass
        self.relation = _relation
        self.fields = _fields

        self.reflect = _klass.relations[_relation.to_s]
        self.inverse_klass = self.reflect.klass
        self.inverse_relation = self.reflect.inverse
      end

      def attach
        # implement in subclasses
      end

      def callback_attached?(callback_type, callback_name)
        !!klass.send(:"_#{callback_type}_callbacks").
          map(&:raw_filter).include?(callback_name)
      end

      def callback_defined?(callback_name)
        klass.method_defined?(callback_name)
      end

      def alias_callback
        unless callback_defined?(aliased_callback_name)
          klass.send(:alias_method, aliased_callback_name, callback_name)
        end
      end

      def callback_name
        "_#{aliased_callback_name}"
      end

      def aliased_callback_name
        "denormalize_#{direction}_#{relation}"
      end

      private

      def joined_fields
        (fields + [:_id]).map {|f| "'#{f}'" }.join(", ")
      end
    end
  end
end
