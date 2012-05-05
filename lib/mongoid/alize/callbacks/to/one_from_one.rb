module Mongoid
  module Alize
    module Callbacks
      module To
        class OneFromOne < ToOneCallback
          protected

          def iterable_relation
            "self.#{relation} ? [self.#{relation}] : []"
          end
        end
      end
    end
  end
end
