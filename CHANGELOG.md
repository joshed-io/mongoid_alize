Mongoid::Alize
==============
> Comprehensive, flexible denormalization for Mongoid that stays in sync

## Changelog

### Release 0.4.0
Support for Mongoid 3.

### Release 0.3.0

See README.md.

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

