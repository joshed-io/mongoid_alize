Mongoid::Alize
==============
> Comprehensive, flexible denormalization for Mongoid that stays in sync

Mongoid Alizé helps you improve your Mongoid application's
read performance by making it easy to store related data together.

Features of Mongoid Alizé
-------------------------
- Extremely light DSL and easy setup
- Works from both sides of one-to-one, one-to-many, and many-to-many relations.
- Callbacks set on both sides of relations keep data in sync. Even on destroys!
- Atomic modifiers and grouped updates used whenever possible for better performance
- Specify lists of fields and methods to denormalize, or default to all fields
- Override individual denormalization callbacks to implement custom behavior like denormalizing asynchronously

Installation
------------
Add the gem to your `Gemfile`:

    gem 'mongoid_alize'

Or install with RubyGems:

    $ gem install mongoid_alize

Usage
-----
Here's a simple use case. A `Post` model would like to denormalize some data about its author - the `User`.

    class Post
      include Mongoid::Document
      include Mongoid::Alize

      field :title
      field :category

      has_one :user

      # ***
      alize :user, :name, :city # denormalize name and city from user
      # ***

    end

    # User data now saves into the Post record
    @post.user = User.create!(:name => "Josh", :city => "San Francisco")
    @post.user_name #=> "Josh"
    @post.user_city #=> "San Francisco"

Here's the inverse case - where we'd like to store Post data into the User record. Note there are 'many' posts.

    class User
      include Mongoid::Document
      include Mongoid::Alize

      field :name
      field :city

      has_many :posts

      # ***
      alize :posts # denormalize all fields from posts (the default w/ no fields specified)
      # ***
    end

    # Post data now saves into the User record
    @user.posts = [Post.create!(:title => "Building a new bike", :category => "Cycling")]
    @user.save!
    @user.posts_fields #=> [{ "title" => "Building a new bike", :category => "Cycling" }]

One-to-one, many-to-one, one-to-many, and many-to-many referenced relations are all supported.

Changes made to the denormalized models will be propagated to the document(s)
where that data has been denormalized for saves *and* destroys.

Migration
---------
Once you've added your alize configuration, your new fields will not yet be populated. Here's what a typical migration looks like:

    User.all.each do |user|
      user.force_denormalization = true
      user.save!
    end

Assuming User is the model w/ denormalized relations, this will iterate over your users and cause alize to denormalize data from the relations you have specified. The `force_denormalization` flag is needed because although the user's relations have not changed you'd like to denormalize them during this save lifecycle anyway.

Advanced Usage
--------------
Callbacks are created as instance methods on the model (in the first example above, these would be `denormalize_from_user` on `Post` and `denormalize_to_posts` on `User`. You can override these to extend behavior. To call the original from your override, simply append a `_` to the front of the method name, so `denormalize_from_user` becomes `_denormalize_from_user`.

This is ideal for say, doing denormalization in the background. The traditional Delayed::Jobs-like approach would be this:

    def denormalize_from_user
      _denormalize_from_user
    end
    handle_asynchronously :denormalize_from_user

(This extra business is needed because it's not always predictable when denormalize methods get defined by a class due to callback methods definitions coming in from the inverse.)

`default_alize_fields` is the method used to generate the denormalization field list when no fields are passed to `alize`. Override to set an alternative field list for your model.

Examples
--------
Check out [spec/mongoid_alize_spec.rb](https://github.com/dzello/mongoid_alize/blob/master/spec/mongoid_alize_spec.rb) to see working examples across all types of relations.

Changelog
---------

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

Tests / Contributing
-------------
The Gemfile has all you need to run the tests (w/ some extras like Guard and debugger). To run the specs:

    bundle install
    bundle exec rspec

Contributions and bug reports are welcome.

Todos/Coming Soon
-----------------
+ Mongoid 3 Support
+ Performance improvements and batch updates
+ Your feature requests and issues!

Credits / License
-------
Mongoid::Alize - Copyright (c) 2012 Josh Dzielak
MIT License

A big thanks to Durran Jordan for creating [Mongoid](http://mongoid.org).
