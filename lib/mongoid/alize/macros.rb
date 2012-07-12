module Mongoid
  module Alize
    module Macros

      attr_accessor :alize_from_callbacks, :alize_to_callbacks

      def alize(relation, *fields)
        alize_from(relation, *fields)
        metadata = self.relations[relation.to_s]
        unless _alize_unknown_inverse?(metadata)
          metadata.klass.alize_to(metadata.inverse, *fields)
        end
      end

      def alize_from(relation, *fields)
        one, many = _alize_relation_types

        from_one  = Mongoid::Alize::Callbacks::From::One
        from_many = Mongoid::Alize::Callbacks::From::Many

        klass = self
        metadata = klass.relations[relation.to_s]
        relation_superclass = metadata.relation.superclass

        callback_klass =
          case [relation_superclass]
          when [one]  then from_one
          when [many] then from_many
          end

        fields = _alize_process_fields(fields, metadata)

        (klass.alize_from_callbacks ||= []) << callback =
          callback_klass.new(klass, relation, fields)
        callback.attach

      end

      def alize_to(relation, *fields)
        one, many = _alize_relation_types

        klass = self
        metadata = klass.relations[relation.to_s]
        relation_superclass = metadata.relation.superclass

        fields = _alize_process_fields(fields, metadata)

        (klass.alize_to_callbacks ||= []) << callback =
          Mongoid::Alize::ToCallback.new(klass, relation, fields)
        callback.attach

      end

      def default_alize_fields
        self.fields.reject { |name, field|
          name =~ /^_/
        }.keys
      end

      private

      def _alize_process_fields(fields, metadata)
        options = fields.extract_options!
        if options[:fields]
          fields = options[:fields]
        elsif fields.empty? && !_alize_unknown_inverse?(metadata)
          fields = metadata.klass.default_alize_fields
        end
        fields
      end

      def _alize_unknown_inverse?(metadata)
        (metadata.polymorphic? && metadata.stores_foreign_key?) ||
          metadata.klass.nil? ||
          metadata.inverse.nil?
      end

      def _alize_relation_types
        one  = Mongoid::Relations::One
        many = Mongoid::Relations::Many

        def (many = many.dup).==(klass)
          [Mongoid::Relations::Many,
           Mongoid::Relations::Referenced::Many].map(&:name).include?(klass.name)
        end

        [one, many]
      end
    end
  end
end
