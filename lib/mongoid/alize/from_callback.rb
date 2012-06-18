module Mongoid
  module Alize
    class FromCallback < Callback

      def attach
        define_fields

        define_callback
        set_callback
      end

      protected

      def set_callback
        klass.set_callback(:create, :before, callback_name)
      end

      def callback_name
        "denormalize_from_#{relation}"
      end

      def ensure_field_not_defined!(prefixed_name, klass)
        if klass.fields[prefixed_name]
          raise Mongoid::Alize::Errors::AlreadyDefinedField.new(prefixed_name, klass.name)
        end
      end
    end
  end
end
