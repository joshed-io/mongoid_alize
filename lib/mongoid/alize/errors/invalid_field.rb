module Mongoid
  module Alize
    module Errors

      class InvalidField < AlizeError
        def initialize(name, inverse_klass)
          super(
            translate("invalid_field", { :name => name, :inverse_klass => inverse_klass })
          )
        end
      end

    end
  end
end
