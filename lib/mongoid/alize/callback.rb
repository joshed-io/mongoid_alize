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
        self.inverse_relation = self.reflect.inverse
        unless self.reflect.polymorphic?
          self.inverse_klass = self.reflect.klass
        end
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

      def define_fields_method
        _fields = fields
        if fields.is_a?(Proc)
          klass.send(:define_method, fields_method_name) do |inverse|
            _fields.bind(self).call(inverse).map(&:to_s)
          end
        else
          klass.send(:define_method, fields_method_name) do |inverse|
            _fields.map(&:to_s)
          end
        end
      end

      def fields_method_name
        "#{callback_name}_fields"
      end

      def field_values(source, options={})
        extras = options[:id] ? "['_id']" : "[]"
        <<-RUBY
          (#{fields_method_name}(#{source}) + #{extras}).inject({}) { |hash, name|
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
