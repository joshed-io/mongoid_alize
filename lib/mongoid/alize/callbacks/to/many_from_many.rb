module Mongoid
  module Alize
    module Callbacks
      module To
        class ManyFromMany < ToManyCallback
          protected

          def iterable_relation
            "self.#{relation}"
          end
        end
      end
    end
  end
end
