require 'rubygems'
require 'mongoid'
require 'mongoid/compatibility'
require 'rr'

unless ENV['CI']
  require 'awesome_print'
  require 'wirble'
end

Mongoid.configure do |config|

  if defined?(Moped)
    Moped.logger = Logger.new($stdout)
    Moped.logger.level = Logger::INFO
  else
    logger = Logger.new($stdout)
    logger.level = Logger::INFO
  end

  name = "mongoid_alize_test"
  config.respond_to?(:connect_to) ? config.connect_to(name) : config.master = Mongo::Connection.new.db(name)
end

require File.expand_path("../../lib/mongoid_alize", __FILE__)
Dir["#{File.dirname(__FILE__)}/app/models/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/helpers/*.rb"].each { |f| require f }

SAVED_FIELDS = {
}

RSpec.configure do |config|
  config.include(MacrosHelper)

  puts "MongoidVersion - #{Mongoid::VERSION}"

  config.mock_with :rr
  config.before :each do
    Mongoid.purge!

    [Head, Person].each do |klass|
      if !SAVED_FIELDS[klass]
        SAVED_FIELDS[klass] = klass.fields.keys | ['_id', '_type']
      end

      klass.alize_from_callbacks = []
      klass.alize_to_callbacks = []
      klass.reset_callbacks(:save)
      klass.reset_callbacks(:create)
      klass.reset_callbacks(:destroy)
      klass.fields.reject! do |field, value|
        !SAVED_FIELDS[klass].include?(field)
      end
      klass.instance_methods.each do |method|
        if method =~ /^_?denormalize_/ && method !~ /_all$/
          klass.send(:undef_method, method)
        end
      end
    end
  end
end
