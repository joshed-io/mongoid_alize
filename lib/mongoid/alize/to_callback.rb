module Mongoid
  module Alize
    class ToCallback < Callback

      def attach
        define_fields

        define_callback
        alias_callback
        set_callback

        define_destroy_callback
        alias_destroy_callback
        set_destroy_callback
      end

      def define_fields
        define_fields_method
      end

      def set_callback
        unless callback_attached?("save", aliased_callback_name)
          klass.set_callback(:save, :after, aliased_callback_name)
        end
      end

      def set_destroy_callback
        unless callback_attached?("destroy", aliased_destroy_callback_name)
          klass.set_callback(:destroy, :after, aliased_destroy_callback_name)
        end
      end

      def alias_destroy_callback
        unless callback_defined?(aliased_destroy_callback_name)
          klass.send(:alias_method, aliased_destroy_callback_name, destroy_callback_name)
        end
      end

      def aliased_destroy_callback_name
        "denormalize_destroy_#{direction}_#{relation}"
      end

      def destroy_callback_name
        "_#{aliased_destroy_callback_name}"
      end

      def prefixed_name
        "#{inverse_relation}_fields"
      end

      def plain_relation
        "self.#{relation}"
      end

      def surrounded_relation
        "self.#{relation} ? [self.#{relation}] : []"
      end

      def direction
        "to"
      end
    end
  end
end
