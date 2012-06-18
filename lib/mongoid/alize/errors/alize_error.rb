module Mongoid
  module Alize
    module Errors

      class AlizeError < Mongoid::Errors::MongoidError
        def translate(key, data={})
          super("alize.#{key}", data)
        end
      end

    end
  end
end
