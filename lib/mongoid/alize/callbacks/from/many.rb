module Mongoid
  module Alize
    module Callbacks
      module From
        class Many < FromCallback

          protected

          def define_callback
            klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
              def #{callback_name}
                self.#{prefixed_name} = self.#{relation}.map do |model|
                  model.attributes.slice(#{joined_fields})
                end
              end

              protected :#{callback_name}
            CALLBACK
          end

          def define_fields
            unless !!klass.fields[prefixed_name]
              klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
                field :#{prefixed_name}, :type => Array
              CALLBACK
            end
          end

          def prefixed_name
            "#{relation}_fields"
          end
        end
      end
    end
  end
end
