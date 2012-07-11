module Mongoid
  module Alize
    module Callbacks
      module From
        class One < FromCallback

          protected

          def define_callback
            klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
              def #{callback_name}#{force_param}
                if #{force_check} ||
                    #{!metadata.stores_foreign_key?} ||
                      self.#{metadata.key}_changed?

                  if relation = self.#{relation}
                    self.#{self.prefixed_name} = #{field_values("relation")}
                  else
                    self.#{self.prefixed_name} = {}
                  end

                end
                true
              end

              protected :#{callback_name}
            CALLBACK
          end

          def define_fields
            ensure_field_not_defined!(prefixed_name, klass)
            klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
              field :#{prefixed_name}, :type => Hash, :default => {}
            CALLBACK

            define_fields_method
          end
        end
      end
    end
  end
end
