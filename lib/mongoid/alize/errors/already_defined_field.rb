module Mongoid
  module Alize
    module Errors

      class AlreadyDefinedField < AlizeError
        def initialize(name, klass)
          super(
            translate("already_defined_field", { :name => name, :klass => klass })
          )
        end
      end

    end
  end
end
