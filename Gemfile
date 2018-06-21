source 'https://rubygems.org'

case rails_version = ENV['RAILS_VERSION'] || "~> 5.2"
when /5/
  gem "rails", "~> 5.2"
when /4/
  gem "rails", "~> 4.2"
when /3/
  gem "rails", "~> 3.2"
else
  gem "rails", rails_version
end

case mongoid_version = ENV['MONGOID_VERSION'] || "~> 6.0"
when /6/
  gem "mongoid", "~> 6.0"
when /5/
  gem "mongoid", "~> 5.0"
when /4/
  gem "mongoid", "~> 4.0"
when /3/
  gem "mongoid", "~> 3.1"
else
  gem "mongoid", mongoid_version
end

group :development, :test do
  gem 'rake'

  gem 'rspec', '2.6.0'
  gem 'rr'

  unless ENV['CI']
    gem 'guard'
    gem 'guard-rspec'
    gem 'ruby_gntp'
    gem 'rb-fsevent'

    # irb goodies
    gem 'awesome_print'
    gem 'wirble'
  end
end

