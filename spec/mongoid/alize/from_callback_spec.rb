require 'spec_helper'

class Mongoid::Alize::SpecFromCallback < Mongoid::Alize::FromCallback
  def define_fields
  end

  def define_callback
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

  describe "#attach" do
    it "should call define_fields" do
      mock(@callback).define_fields
      @callback.send(:attach)
    end

    it "should call define_callback" do
      mock(@callback).define_callback
      @callback.send(:attach)
    end

    it "should call set_callback" do
      mock(@callback).set_callback
      @callback.send(:attach)
    end

    it "should not set the callback if it's already set" do
      @callback.send(:attach)
      dont_allow(@callback).set_callback
      @callback.send(:attach)
    end
  end
end
