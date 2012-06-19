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

        self.klass.send(:attr_accessor, :force_denormalization)
        self.inverse_klass.send(:attr_accessor, :force_denormalization)
      end

      def attach
        # implement in subclasses
      end

      protected

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

      def joined_fields
        (fields + [:_id]).map {|f| "'#{f}'" }.join(", ")
      end

      def joined_field_values(source)
        <<-RUBY
          [#{joined_fields}].inject({}) { |hash, name|
            hash[name] = #{source}.send(name)
            hash
          }
        RUBY
      end

      def force_param
        "(force=false)"
      end

      def force_check
        "force || self.force_denormalization"
      end
    end
  end
end
