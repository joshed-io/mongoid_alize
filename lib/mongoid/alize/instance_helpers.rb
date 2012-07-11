module Mongoid
  module Alize
    module InstanceHelpers

      attr_accessor :force_denormalization

      def denormalize_from_all
        run_alize_callbacks(self.class.alize_callbacks)
      end

      def denormalize_to_all
        run_alize_callbacks(self.class.alize_inverse_callbacks)
      end

      private

      def run_alize_callbacks(callbacks)
        callbacks.each do |callback|
          self.send(callback.aliased_callback_name)
        end
      end

    end
  end
end
