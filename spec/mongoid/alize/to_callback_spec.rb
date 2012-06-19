require 'spec_helper'

class Mongoid::Alize::SpecToCallback < Mongoid::Alize::ToCallback
  def define_callback
  end

  def define_destroy_callback
  end
end

describe Mongoid::Alize::ToCallback do
  def klass
    Mongoid::Alize::SpecToCallback
  end

  def args
    [Person, :head, [:name, :location, :created_at]]
  end

  def new_callback
    klass.new(*args)
  end

  before do
    @callback = new_callback
  end

  describe "#attach" do
    it "should call define_callback" do
      mock(@callback).define_callback
      @callback.send(:attach)
    end

    it "should call set_callback" do
      mock(@callback).set_callback
      @callback.send(:attach)
    end

    it "should call define_destroy_callback" do
      mock(@callback).define_destroy_callback
      @callback.send(:attach)
    end

    it "should call set_destroy_callback" do
      mock(@callback).set_destroy_callback
      @callback.send(:attach)
    end

    it "should not set the callback if it's already set" do
      @callback.send(:attach)
      dont_allow(@callback).set_callback
      @callback.send(:attach)
    end

    it "should not set the destroy callback if it's already set" do
      @callback.send(:attach)
      dont_allow(@callback).set_destroy_callback
      @callback.send(:attach)
    end
  end
end
