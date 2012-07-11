module Mongoid
  module Alize
    class ToOneCallback < ToCallback
      protected

      def define_callback
        _callback(callback_name, field_values("self"))
      end

      def define_destroy_callback
        _callback(destroy_callback_name, "{}")
      end

      def _callback(_callback_name, field_sets)
        klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
          def #{_callback_name}#{force_param}
            (#{iterable_relation}).each do |relation|
              field_values = #{field_sets}
              relation.set(:#{prefixed_name}, field_values)
            end
            true
          end
          protected :#{_callback_name}
        CALLBACK
      end
    end
  end
end
