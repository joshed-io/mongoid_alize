module Mongoid
  module Alize
    class ToOneCallback < ToCallback
      protected

      def define_callback
        _callback(callback_name, to_one_field_sets)
      end

      def define_destroy_callback
        _callback(destroy_callback_name, to_one_destroy_field_sets)
      end

      def to_one_field_sets
        fields.map { |field|
          "relation.set(:#{prefixed_field_name(field)}, self.read_attribute(:#{field}))"
        }.join("\n")
      end

      def to_one_destroy_field_sets
        fields.map { |field|
          "relation.set(:#{prefixed_field_name(field)}, nil)"
        }.join("\n")
      end

      def _callback(_callback_name, field_sets)
        klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
          def #{_callback_name}
            (#{iterable_relation}).each do |relation|
              #{field_sets}
            end
            true
          end
        CALLBACK
      end

      def prefixed_field_name(name)
        "#{inverse_relation}_#{name}"
      end
    end
  end
end
