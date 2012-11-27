Mongoid::Alize
==============
> Comprehensive, flexible denormalization for Mongoid that stays in sync

## Changelog

### Release 0.4.0
Support for Mongoid 3.

### Release 0.3.0

#### Unifying how data is stored

mongoid_alize 0.3.0 is imcompatible with previous versions for one-to-one relations. Previous versions defined fields of the form `%{relation}_%{field_name}`, e.g. `post_username` to store the username from post. This caused the implementation of one-to-one and one-to-many relations to be quite different, and it made handling polymorphic associations infeasible because fields are different for each related model. There are several other reasons why this setup wasn't optimal: data types for one-to-ones had to be considered up-front, and creating distinct groups of denormalized fields based on the same relation (something planned for in the future) wouldn't be possible. Last but not least, this makes the eventual handling of this JSON by a client more symmetrical (e.g. my code to instantiate nested Backbone.js models from denormalized data became much more concise).

The bottom line is that it all works the same now. If you're doing a one-to-one from a `user` relation, the denormalized data is stored as a Hash in a `user_fields`. If you are doing a many-to-one, it's still `user_fields` - but as an Array. And if it's polymorphic in either case, it's still `user_fields`, but the fields stored might be different each time.

#### Polymorphic support

Polymorphic relations are supported. That said, there are two things to be aware of.

One is the natural limitation of the `alize` macro when it comes to polymorphic relations - the Class of the object stored by the relation is known only at runtime. So, when you specify `alize` on the polymorphic side (the side with the `:polymorphic => true` argument to the relation), `alize` cannot apply the to-side macro automatically - it doesn't know how to find the inverse(s). To still get to-side behavior, you'll need to add the `alize_to` macro for any class/relation that can be an inverse (i.e. any relation that uses the `:as => :something` parameter to the relation definition.)

The second challenge is that the fields to denormalize will likely be different on per-inverse basis. Perhaps your `:addressable` relation can store both homes and offices but needs to store different fields for each (e.g. offices have a company name, and homes belong to owners). This can be accomplished by passing a proc to the `:fields` option key when defining the relation. The block will be passed the model instance in question:

    alize :addressable, :fields => lambda { |addressable|
      if addressable.is_a?(Home)
        [:owner_name]
      elsif addressable.is_a?(Office)
        [:company_name]
      end
    }

Protip - In practice, rather than doing ugly type checking, I implement a method on any class that can be addressable that returns a list of fields:

    class Home
      def alize_fields_for_addressable
        [:owner_name]
      end
    end

    class Office
      def alize_fields_for_addressable
        [:company_name]
      end
    end

    alize :addressable, :fields => lambda { |addressable| addressable.alize_fields_for_addressable }

Note the fields option is valid for anything you alize.

### denormalize_from_all and denormalize_to_all hooks
Each class where `Mongoid::Alize` is included has two new methods - `denormalize_from_all` and `denormalize_to_all`. These methods run all of the alize callbacks (in the appropriate direction) for that model.

This comes in handy when you want to trigger denormalization without going through the save callback cycle. Keep in mind that denormalize_from methods do not automatically persist the data that's updated in the model (b/c they're traditionally used in a before save). So if you call `denormalize_from_all` you'll need to handle persistance yourself - usually through atomic mongoid operations like `set`.

Protip: If you need even more flexibility, you now have access to alize's callback metadata in either direction via the class methods `alize_from_callbacks` and `alize_to_callbacks`. Each is an array of `Mongoid::Alize::Callback` objects.

Protip #2: Make sure to pair with the `force_denormalization` attr if you want all callbacks to skip dirty checking (appropriate for batch updates, sync-ing stale data, etc)

Protip #3: I use this to fire `to` denormalizations after `to` denormalizations (and this will be the default behavior soon). If you are denormalizing denormalized data (meta, I know) you can use this to make sure updates to a model trigger denormalization to *it's* model's.

### Speed
One-to-one performance is dramatically improved. Updating all fields is accomplished via one `set` operation.

#### Misc 0.3.0 updates
- `alize_to` and `alize_from` are available separately if you only want one type of behavior for a relation. `alize` still does both (except for polymorphic relations, in which case it acts as `alize_from`)
- You can pass a `:fields` proc to any `alize` to dynamically determine stores fields at the instance level.

#### Upgrading
You'll need to rewrite the parts of your application that use one-to-one denormalization. Instead of finding data in a `post_title` field, you'll be looking in `post_fields["title"]`.
After updating your code, re-denormalize your data with 0.3.0 installed (loop through objects and call save with the `force_denormalization` attr set to true).

#### Will the API keep changing?
It's my intent to follow the [Semantic Versioning Spec](http://semver.org). So until 1.0, it's possible that breaking changes may be introduced. I'll do my best to outline the changes each time and give advice on how to respond to changes. The goal is to get to 1.0 as quickly as possible, but there is still some real-world mileage to cover.

### Release 0.2.0

#### denormalize_from callbacks now invoked on save

These callbacks are now called on save in addition to create. This makes sure that modified relations get picked up and denormalized fields get changed as a result. Where predictable dirty checking is possible it is used to skip unneeded callbacks. Where a dirty status cannot reliably be inferred, the denormalize callback is triggered. While there might be a slight performance hit, I believe the guarantee of consistent data is more important. Future optimizations will be able to skip callbacks more eagerly.

#### Denormalization of methods (a.k.a lazily computed pseudo-attributes) is now supported for all relations

Because methods don't have explicit return types, there are a few rules around the type definition of the field that will hold the method's data.

+ If the field isn't defined it's type will be set to `String`.
+ If a field is already defined, it will not be redefined. This allows you to define the field in advance and give it the type you like.

For example, if you are denormalizing a method `User#birthday` and you'd like birthday to be stored as a date, you might do this:

    class Invitation
      belongs_to :user
      field :user_birthday, Date
      alize :user, :birthday
    end

#### Method aliasing

The generated, public `denormalize_to_foo` callbacks now also have protected aliases that begin with \_. And alize will not override these callbacks if you have already set them. This allows you to define the callbacks yourselves, do whatever you need, and tell alize to do what it otherwise would. This also makes it possible to annotate methods (i.e. `handle_asynchronously`) because can control the place at which they are defined.

#### Other misc updates
+ Several performance boosts via combining field updates and dirty checking. (That said, the big performance gains like advanced dirty checking and bulk updates are coming in 0.3. This release was focused on features and usability.)
+ Duplicate callbacks no longer added due to development environment class reloading
+ Error classes w/ I18n support. Errors where fields in the alize definition do not exist are raised.
+ Denormalize `:id` just like any other attribute in any relation type.
+ A `force` param for the aliased denormalize methods (to skip dirty checking) as well as a `force_denormalization` attribute to instruct a class to fire all callbacks regardless of dirty status.
+ Updated 'scenario' spec - `mongoid_alize_spec.rb` with new use cases

