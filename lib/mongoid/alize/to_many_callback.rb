module Mongoid
  module Alize
    class ToManyCallback < ToCallback
      protected

      def define_callback
        _callback(callback_name,
                  "inverse.push(:#{prefixed_name}, self.attributes.slice(#{joined_fields}))")
      end

      def define_destroy_callback
        _callback(destroy_callback_name)
      end

      def _callback(_callback_name, push_content="")
        klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
          def #{_callback_name}

            (#{iterable_relation}).each do |inverse|

              # this pull works in the DB, but not in memory
              # ($pull w/ expression not currently supported by Mongoid)
              inverse.pull(:#{prefixed_name}, { "_id" => self.id })

              # manually do the pull in memory for now
              if inverse.#{prefixed_name}
                inverse.#{prefixed_name}.reject! do |hash|
                  hash["_id"] == self.id
                end
              end

              #{push_content}
            end
          end

          protected :#{_callback_name}
        CALLBACK
      end

      def prefixed_name
        "#{inverse_relation}_fields"
      end
    end
  end
end
