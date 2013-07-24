module Mongoid
  module Alize
    module Callbacks
      module From
        class Many < FromCallback

          protected

          def define_callback
            klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
              def #{callback_name}#{force_param}
                self.#{prefixed_name} = self.#{relation}.map do |relation|
                  #{field_values("relation", :id => true)}
                end
                true
              end

              protected :#{callback_name}
            CALLBACK
          end

          def define_fields
            ensure_field_not_defined!(prefixed_name, klass)
            klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
              field :#{prefixed_name}, :type => Array, :default => []
            CALLBACK
          end
        end
      end
    end
  end
end
