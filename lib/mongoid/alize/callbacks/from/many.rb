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
                  [#{joined_fields}].inject({}) { |hash, name|
                    hash[name] = model.send(name)
                    hash
                  }
                end
              end
            CALLBACK
          end

          def define_fields
            ensure_field_not_defined!(prefixed_name, klass)
            klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
              field :#{prefixed_name}, :type => Array, :default => []
            CALLBACK
          end

          def prefixed_name
            "#{relation}_fields"
          end
        end
      end
    end
  end
end
