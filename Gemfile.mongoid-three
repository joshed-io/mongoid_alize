source 'https://rubygems.org'

group :development, :test do
  gem 'rake'
  gem 'mongoid', '~> 3'

  gem 'rspec'
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

