module Mongoid
  module Alize
    class Callback

      attr_accessor :fields

      attr_accessor :klass
      attr_accessor :relation

      attr_accessor :inverse_klass
      attr_accessor :inverse_relation

      def initialize(_klass, _relation, _fields)
        self.klass = _klass
        self.relation = _relation
        self.fields = _fields

        reflect = _klass.relations[_relation.to_s]
        self.inverse_klass = reflect.klass
        self.inverse_relation = reflect.inverse
      end

      def attach
        # implement in subclasses
      end

      def callback_attached?(klass, callback_type, callback_name)
        !!klass.send(:"_#{callback_type}_callbacks").
          map(&:raw_filter).include?(callback_name)
      end

      private

      def joined_fields
        (fields + [:_id]).map {|f| "'#{f}'" }.join(", ")
      end
    end
  end
end
