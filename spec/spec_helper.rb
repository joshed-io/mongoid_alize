require 'rubygems'
require 'looksee'
require 'awesome_print'
require 'wirble'
require 'mongoid'

module SpecHelper
  def self.mongoid_3?
    defined?(Mongoid::VERSION) && Mongoid::VERSION =~ /^3/
  end
end

Mongoid.configure do |config|
  if SpecHelper.mongoid_3?
    config.connect_to("mongoid_alize_test")
    Moped.logger = Logger.new($stdout)
    Moped.logger.level = Logger::INFO
  else
    logger = Logger.new($stdout)
    logger.level = Logger::INFO
    config.master = Mongo::Connection.new("localhost", 27017,
                    :logger => logger).db("mongoid_alize_test")
  end
end

require File.expand_path("../../lib/mongoid_alize", __FILE__)
Dir["#{File.dirname(__FILE__)}/app/models/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/helpers/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include(MacrosHelper)

  puts "MongoidVersion - #{Mongoid::VERSION}"

  config.mock_with :rr
  config.before :each do
    Mongoid.purge!

    persistent_fields = {
      Object => [:_id, :_type],
      Person => [:name, :created_at, :want_ids, :seen_by_id],
      Head => [:size, :weight, :person_id, :captor_id, :wanted_by_ids]
    }

    [Head, Person].each do |klass|
      klass.alize_from_callbacks = []
      klass.alize_to_callbacks = []
      klass.reset_callbacks(:save)
      klass.reset_callbacks(:create)
      klass.reset_callbacks(:destroy)
      klass.fields.reject! do |field, value|
        !(persistent_fields[klass] +
          persistent_fields[Object]).include?(field.to_sym)
      end
      klass.instance_methods.each do |method|
        if method =~ /^_?denormalize_/ && method !~ /_all$/
          klass.send(:undef_method, method)
        end
      end
    end
  end
end
