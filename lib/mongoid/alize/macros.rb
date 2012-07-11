module Mongoid
  module Alize
    module Macros

      attr_accessor :alize_callbacks, :alize_inverse_callbacks

      def alize(relation, *fields)

        options = fields.extract_options!

        one  = Mongoid::Relations::One
        many = Mongoid::Relations::Many

        def (many = many.dup).==(klass)
          [Mongoid::Relations::Many,
           Mongoid::Relations::Referenced::Many].map(&:name).include?(klass.name)
        end

        klass = self
        metadata = klass.relations[relation.to_s]

        fields = default_alize_fields(metadata) if fields.empty?
        fields = options[:fields] if options[:fields]

        from_one  = Mongoid::Alize::Callbacks::From::One
        from_many = Mongoid::Alize::Callbacks::From::Many

        relation_superclass = metadata.relation.superclass
        callback_klass =
          case [relation_superclass]
          when [one]  then from_one
          when [many] then from_many
          end

        (klass.alize_callbacks ||= []) << callback =
          callback_klass.new(klass, relation, fields)
        callback.attach

        unless metadata.polymorphic?
          inverse_klass = metadata.klass
          inverse_relation = metadata.inverse

          if inverse_klass &&
              (inverse_metadata = inverse_klass.relations[inverse_relation.to_s])

            to_one_from_one   = Mongoid::Alize::Callbacks::To::OneFromOne
            to_one_from_many  = Mongoid::Alize::Callbacks::To::OneFromMany
            to_many_from_one  = Mongoid::Alize::Callbacks::To::ManyFromOne
            to_many_from_many = Mongoid::Alize::Callbacks::To::ManyFromMany

            inverse_relation_superclass = inverse_metadata.relation.superclass
            inverse_callback_klass =
              case [relation_superclass, inverse_relation_superclass]
              when [one,  one]  then to_one_from_one
              when [many, one]  then to_many_from_one
              when [one,  many] then to_one_from_many
              when [many, many] then to_many_from_many
              end

            (inverse_klass.alize_inverse_callbacks ||= []) << inverse_callback =
              inverse_callback_klass.new(inverse_klass, inverse_relation, fields)
            inverse_callback.attach
          end
        end
      end

      def default_alize_fields(metadata)
        if metadata.polymorphic?
          []
        else
          metadata.klass.
            fields.reject { |name, field|
            name =~ /^_/
          }.keys
        end
      end
    end
  end
end
