source 'https://rubygems.org'

group :development, :test do
  gem 'mongoid'
  gem 'bson_ext', '1.6.1'

  gem 'rspec'
  gem 'rr'

  gem 'guard'
  gem 'guard-rspec'
  gem 'ruby_gntp'
  # only load these on OSX
  gem 'rb-fsevent', :require => (RUBY_PLATFORM.include?('darwin') and 'rb-fsevent')
  # readline gives a prompt and history for guard command line
  gem 'rb-readline', :require => (RUBY_PLATFORM.include?('darwin') and 'rb-fsevent')

  # irb goodies
  gem 'awesome_print'
  gem 'wirble'
  gem 'looksee'
  gem 'debugger'
end

