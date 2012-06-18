module Mongoid
  module Alize
    module Callbacks
      module From
        class One < FromCallback

          protected

          def define_callback
            field_sets = ""
            fields.each do |name|
              field_sets << "self.set(:#{prefixed_field_name(name)}, relation && relation.read_attribute(:#{name}))\n"
            end

            klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
              def #{callback_name}
                relation = self.#{relation}
                #{field_sets}
                true
              end
            CALLBACK
          end

          def define_fields
            fields.each do |name|
              prefixed_name = prefixed_field_name(name)
              klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
                field :#{prefixed_name}, :type => #{inverse_field_type(name)}
              CALLBACK
            end
          end

          def prefixed_field_name(name)
            "#{relation}_#{name}"
          end

          def inverse_field_type(name)
            field = inverse_klass.fields[name.to_s]
            if field
              field.options[:type] ? field.type : String
            else
              raise Mongoid::Alize::Errors::InvalidField.new(name, inverse_klass.name)
            end
          end
        end
      end
    end
  end
end
