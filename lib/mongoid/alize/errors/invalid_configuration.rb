module Mongoid
  module Alize
    module Errors

      class InvalidConfiguration < AlizeError
        def initialize(reason, klass, relation)
          super(
            translate("invalid_configuration.#{reason}",
                        { :klass => klass, :relation => relation })
          )
        end
      end

    end
  end
end
