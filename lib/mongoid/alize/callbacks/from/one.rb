module Mongoid
  module Alize
    module Callbacks
      module From
        class One < FromCallback

          protected

          def define_callback
            field_sets = ""
            fields.each do |name|
              field_sets << "self.send(:#{prefixed_field_name(name)}=,
                               relation && relation.send(:#{name}))\n"
            end

            klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
              def #{callback_name}#{force_param}
                if #{force_check} ||
                    #{!reflect.stores_foreign_key?} ||
                    self.#{reflect.key}_changed?
                  relation = self.#{relation}
                  #{field_sets}
                end
                true
              end

              protected :#{callback_name}
            CALLBACK
          end

          def define_fields
            fields.each do |name|
              prefixed_name = prefixed_field_name(name)
              unless field_defined?(prefixed_name, klass)
                klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
                  field :#{prefixed_name}, :type => #{inverse_field_type(name)}
                CALLBACK
              end
            end
          end

          def prefixed_field_name(name)
            "#{relation}_#{name}"
          end

          def inverse_field_type(name)
            name = name.to_s

            name = "_id" if name == "id"
            name = "_type" if name == "type"

            field = inverse_klass.fields[name]
            (field && field.options[:type]) ? field.type : String
          end
        end
      end
    end
  end
end
