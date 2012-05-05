module Mongoid
  module Alize
    module Macros

      def alize(relation, *fields)

        fields = default_alize_fields(relation) if fields.empty?

        one  = Mongoid::Relations::One
        many = Mongoid::Relations::Many

        def (many = many.dup).==(klass)
          [Mongoid::Relations::Many,
           Mongoid::Relations::Referenced::Many].map(&:name).include?(klass.name)
        end

        klass = self
        reflect = klass.relations[relation.to_s]

        from_one  = Mongoid::Alize::Callbacks::From::One
        from_many = Mongoid::Alize::Callbacks::From::Many

        relation_superclass = reflect.relation.superclass
        callback_klass =
          case [relation_superclass]
          when [one]  then from_one
          when [many] then from_many
          end

        callback_klass.
          new(klass, relation, fields).
          attach

        inverse_klass = reflect.klass
        inverse_relation = reflect.inverse

        if inverse_klass &&
            (inverse_reflect = inverse_klass.relations[inverse_relation.to_s])

          to_one_from_one   = Mongoid::Alize::Callbacks::To::OneFromOne
          to_one_from_many  = Mongoid::Alize::Callbacks::To::OneFromMany
          to_many_from_one  = Mongoid::Alize::Callbacks::To::ManyFromOne
          to_many_from_many = Mongoid::Alize::Callbacks::To::ManyFromMany

          inverse_relation_superclass = inverse_reflect.relation.superclass
          inverse_callback_klass =
            case [relation_superclass, inverse_relation_superclass]
            when [one,  one]  then to_one_from_one
            when [many, one]  then to_many_from_one
            when [one,  many] then to_one_from_many
            when [many, many] then to_many_from_many
            end

          inverse_callback_klass.
            new(inverse_klass, inverse_relation, fields).
            attach
        end
      end

      def default_alize_fields(relation)
        self.relations[relation.to_s].klass.
          fields.reject { |name, field|
          name =~ /^_/
        }.keys
      end
    end
  end
end
