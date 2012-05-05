Mongoid::Alize
==============
> Comprehensive field denormalization for Mongoid that stays in sync

Mongoid Alize helps you improve your Mongoid application's
read performance by making it easy to store related data together.

Features of Mongoid Alize
-------------------------
- Extremely light DSL and easy setup
- Works from both sides of one-to-one, one-to-many, and many-to-many relations.
- Callbacks set on both sides of relations keep data in sync. Even on destroys!
- Atomic modifiers and grouped updates used whenever possible for better performance
- Specify lists of fields to denormalize, or default to all fields
- Override individual denormalization callbacks to implement custom behavior

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
      alize :user, :name, :city # denormalize the user relation
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
      alize :posts # denormalize the posts relation
      # ***
    end

    # Post data now saves into the User record
    @user.posts << Post.create!(:title => "Building a new bike", :category => "Cycling")
    @user.posts_fields #=> [{ "title" => "Building a new bike", :category => "Cycling" }]

You can also specify the exact list of fields you'd like denormalized (the default is all non-system fields):

    class User
      ...

      # ***
      alize :posts, :title # denormalize the title field only
      # ***

    end

    # ONLY the title attribute of posts are saved into the user record
    @user.posts << Post.create!(:title => "Building a new bike", :category => "Cycling")
    @user.posts_fields #=> [{ "title" => "Building a new bike" }]

One-to-one, many-to-one, one-to-many, and many-to-many referenced relations should all work.

Changes made to the denormalized models will be pushed to the collections
where that data has been replicated. This goes for saves *and* destroys.

Advanced
--------
Callbacks are created as instance methods on the model (in the first example above, these
would be `denormalize_from_user` on `Post` and `denormalize_to_posts` on `User`.
You can override these to extend behavior.

`default_alize_fields` is the method used to generate the denormalization field list when no fields are passed to `alize`. Override to set an alternative field list for your model.

General note - Make sure to define any overrides after including Mongoid::Alize.

Check out `spec/mongoid_alize_spec.rb` to see working examples across all types of relations.

Tests / Contributing
-------------
The Gemfile has all you need to run the tests (w/ some extras like Guard and debugger). To run the specs:

    bundle install
    bundle exec rspec

Contributions and bug reports are welcome.

Todos/Coming Soon
-----------------
+ Support for polymorphic associations
+ More examples and documentation.
+ Your feature requests!

Credits / License
-------
Mongoid::Alize - Copyright (c) 2012 Josh Dzielak

A big thanks to Durran Jordan for creating [Mongoid](http://mongoid.org).
