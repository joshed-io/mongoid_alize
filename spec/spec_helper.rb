require 'rubygems'
require 'looksee'
require 'awesome_print'
require 'wirble'
require 'mongoid'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new("localhost", 27017,
                    :logger => Logger.new("log/test.log")).db("mongoid_alize_test")
end

require File.expand_path("../../lib/mongoid_alize", __FILE__)
Dir["#{File.dirname(__FILE__)}/app/models/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/helpers/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include(MacrosHelper)

  config.mock_with :rr
  config.before :each do
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)

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
