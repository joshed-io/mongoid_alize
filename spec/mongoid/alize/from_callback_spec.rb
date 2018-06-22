require 'spec_helper'

class Mongoid::Alize::SpecFromCallback < Mongoid::Alize::FromCallback
  def define_mongoid_field
  end

  def define_callback
    klass.class_eval <<-CALLBACK
      def _denormalize_from_person
      end
    CALLBACK
  end
end

describe Mongoid::Alize::FromCallback do
  def klass
    Mongoid::Alize::SpecFromCallback
  end

  def args
    [Head, :person, [:name, :location, :created_at]]
  end

  def new_callback
    klass.new(*args)
  end

  before do
    @callback = new_callback
  end

  describe "#set_callback" do
    it "should set a callback on the klass" do
      mock(@callback.klass).set_callback(:save, :before, :denormalize_from_person)
      @callback.send(:set_callback)
    end

    it "should not set the callback if it's already set" do
      @callback.send(:attach)
      dont_allow(@callback.klass).set_callback
      @callback.send(:set_callback)
    end
  end
end
