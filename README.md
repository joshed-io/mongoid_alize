Mongoid::Alize
==============

[![Build Status](https://secure.travis-ci.org/dzello/mongoid_alize.png?branch=master)](http://travis-ci.org/dzello/mongoid\_alize)
[![Code Climate](https://codeclimate.com/github/dzello/mongoid_alize.png)](https://codeclimate.com/github/dzello/mongoid\_alize)

**Comprehensive, flexible denormalization for Mongoid that stays in sync**

> Everything *and* the kitchen sync...

Mongoid Alizé helps you improve your Mongoid application's read performance by making it easy to store related data together.

Features of Mongoid Alizé
-------------------------
- Extremely light DSL and easy setup
- Works with one-to-one, one-to-many, and many-to-many relations.
- Callbacks set on both sides of relations keep data in sync. Even on destroys!
- Atomic modifiers are used for superior performance.
- Supports polymorphic relations as of 0.3.0.
- Custom callbacks and exposed metadata provide flexibility and extensibility (e.g. asynchronous denormalization)
- Comprehensive test suite with dozens of examples
- The [wiki](https://github.com/dzello/mongoid_alize/wiki), soon to be full of war stories and protips.
- Supports mongoid 4+ (experimental), mongoid 3+ and mongoid 2.4+

Installation
------------
Add the gem to your `Gemfile`:

``` ruby
gem 'mongoid_alize'
```

Or install with RubyGems:

``` shell
$ gem install mongoid_alize
```

Usage
-----
Here's a simple use case. A `Post` model would like to denormalize some data about its author - the `User`.

``` ruby
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
@post.user_fields["name"] #=> "Josh"
@post.user_fields["city"] #=> "San Francisco"
```

Here's another case - where we'd like to store Post data into the User record. Note there are 'many' posts.

``` ruby
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
@user.posts << Post.create!(:title => "Building a new bike", :category => "Cycling")
@user.posts << Post.create!(:title => "Bay Area Kayaking", :category => "Kayaking")
@user.posts_fields #=> [{ "title" => "Building a new bike", :category => "Cycling" },
                   #    { "title" => "Bay Area Kayaking", :category => "Kayaking" }]
```

One-to-one, many-to-one, one-to-many, and many-to-many referenced relations are all supported.

Changes made to the denormalized models will be propagated to the document(s)
where that data has been denormalized for saves *and* destroys.

Migration / First-time installation
-----------------------------------
Once you've added your alize configuration you'll need to populate your new fields with data. Here's what a typical migration looks like for one model:

``` ruby
User.all.each do |user|
  user.force_denormalization = true
  user.save!
end
```

Assuming User is the model w/ denormalized relations, this will iterate over your users and cause alize to denormalize data from the relations you have specified. Because the user's relations have not "changed" (in the ActiveModel attributes sense) the `force_denormalization` flag is needed.

### Migrating from mongoid_denormalize

Here's a simple example on how to migrate from another denormalization framework. This code moves the `user_name` field
to `user_fields[name]`.

``` ruby
for post in posts
  post.set(:user_fields, :name => post["user_name"])
  post.unset(:user_name)
end
```

Advanced Usage
--------------
Callbacks are created as instance methods on the model (in the first example above, these would be `denormalize_from_user` on `Post` and `denormalize_to_posts` on `User`. You can override these to extend behavior. To call the original from your override, simply append a `_` to the front of the method name, so `denormalize_from_user` becomes `_denormalize_from_user`.

This is ideal for say, doing denormalization in the background. The traditional Delayed::Jobs-like approach would be this:

``` ruby
def denormalize_from_user
  _denormalize_from_user
end
handle_asynchronously :denormalize_from_user
```

(Note: This extra business is needed because it's not always predictable when denormalize methods get defined by a class since callback method definitions can be defined from the inverse side.)

`default_alize_fields` is the method used to generate the denormalization field list when no fields are passed to `alize`. Override to set an alternative field list for your model.

Examples and specs
------------------
Check out [spec/mongoid_alize_spec.rb](https://github.com/dzello/mongoid_alize/blob/master/spec/mongoid_alize_spec.rb) to see working examples across all types of relations.

Changelog
---------
### Release 0.4.2
Several issues and pull requests fixed. Thanks [johnnyshields](https://github.com/johnnyshields)!

### Release 0.4.0
Now supporting Mongoid 3.

### Release 0.3.0

#### Unifying how data is stored

mongoid_alize 0.3.0 is imcompatible with previous versions for one-to-one relations. Previous versions defined fields of the form `%{relation}_%{field_name}`, e.g. `post_username` to store the username from post. This caused the implementation of one-to-one and one-to-many relations to be quite different, and it made handling polymorphic associations infeasible because fields are different for each related model. There are several other reasons why this setup wasn't optimal: data types for one-to-ones had to be considered up-front, and creating distinct groups of denormalized fields based on the same relation (something planned for in the future) wouldn't be possible. Last but not least, this makes the eventual handling of this JSON by a client more symmetrical (e.g. my code to instantiate nested Backbone.js models from denormalized data became much more concise).

The bottom line is that it all works the same now. If you're doing a one-to-one from a `user` relation, the denormalized data is stored as a Hash in a `user_fields`. If you are doing a many-to-one, it's still `user_fields` - but as an Array. And if it's polymorphic in either case, it's still `user_fields`, but the fields stored might be different each time.

#### Polymorphic support

Polymorphic relations are supported. That said, there are two things to be aware of.

One is the natural limitation of the `alize` macro when it comes to polymorphic relations - the Class of the object stored by the relation is known only at runtime. So, when you specify `alize` on the polymorphic side (the side with the `:polymorphic => true` argument to the relation), `alize` cannot apply the to-side macro automatically - it doesn't know how to find the inverse(s). To still get to-side behavior, you'll need to add the `alize_to` macro for any class/relation that can be an inverse (i.e. any relation that uses the `:as => :something` parameter to the relation definition.)

The second challenge is that the fields to denormalize will likely be different on per-inverse basis. Perhaps your `:addressable` relation can store both homes and offices but needs to store different fields for each (e.g. offices have a company name, and homes belong to owners). This can be accomplished by passing a proc to the `:fields` option key when defining the relation. The block will be passed the model instance in question:

``` ruby
alize :addressable, :fields => lambda { |addressable|
  if addressable.is_a?(Home)
    [:owner_name]
  elsif addressable.is_a?(Office)
    [:company_name]
  end
}
```

Protip - In practice, rather than doing ugly type checking, I implement a method on any class that can be addressable that returns a list of fields:

``` ruby
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
```

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


Tests / Contributing
-------------
The Gemfile has all you need to run the tests (w/ some extras like Guard and debugger). To run the specs:

``` shell
bundle install
bundle exec rspec
```

Contributions and bug reports are welcome.

Todos/Coming Soon
-----------------
+ Performance improvements
+ Your feature requests and issues!

Credits / License
-------
Mongoid::Alize - Copyright (c) 2012 Josh Dzielak
MIT License

A big thanks to Durran Jordan for creating [Mongoid](http://mongoid.org).
