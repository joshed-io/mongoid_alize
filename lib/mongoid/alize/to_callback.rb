module Mongoid
  module Alize
    class ToCallback < Callback

      def attach
        define_callback
        set_callback

        define_destroy_callback
        set_destroy_callback
      end

      protected

      def set_callback
        klass.set_callback(:save, :after, callback_name)
      end

      def set_destroy_callback
        klass.set_callback(:destroy, :after, destroy_callback_name)
      end

      def callback_name
        "denormalize_to_#{relation}"
      end

      def destroy_callback_name
        "denormalize_destroy_to_#{relation}"
      end

      def plain_relation
        "self.#{relation}"
      end

      def surrounded_relation
        "self.#{relation} ? [self.#{relation}] : []"
      end
    end
  end
end
