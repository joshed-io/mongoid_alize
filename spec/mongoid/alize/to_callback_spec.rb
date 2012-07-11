require 'spec_helper'

class Mongoid::Alize::SpecToCallback < Mongoid::Alize::ToCallback
  def define_callback
    klass.class_eval <<-CALLBACK
      def _denormalize_to_head
      end
    CALLBACK
  end

  def define_destroy_callback
    klass.class_eval <<-CALLBACK
      def _denormalize_destroy_to_head
      end
    CALLBACK
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

  describe "names" do
    it "should assign a destroy callback name" do
      @callback.destroy_callback_name.should == "_denormalize_destroy_to_head"
    end

    it "should assign an aliased destroy callback name" do
      @callback.aliased_destroy_callback_name.should == "denormalize_destroy_to_head"
    end

    it "should assign a prefixed name from the inverse" do
      @callback.prefixed_name.should == "person_fields"
    end
  end

  describe "#define_fields" do
    it "should define the fields method" do
      mock(@callback).define_fields_method
      @callback.send(:define_fields)
    end
  end

  describe "#set_callback" do
    it "should set a callback on the klass" do
      mock(@callback.klass).set_callback(:save, :after, "denormalize_to_head")
      @callback.send(:set_callback)
    end

    it "should not set the callback if it's already set" do
      @callback.send(:attach)
      dont_allow(@callback.klass).set_callback
      @callback.send(:set_callback)
    end
  end

  describe "#set_destroy_callback" do
    it "should set a destroy callback on the klass" do
      mock(@callback.klass).set_callback(:destroy, :after, "denormalize_destroy_to_head")
      @callback.send(:set_destroy_callback)
    end

    it "should not set the destroy callback if it's already set" do
      @callback.send(:attach)
      dont_allow(@callback.klass).set_callback
      @callback.send(:set_destroy_callback)
    end
  end

  describe "#alias_destroy_callback" do
    it "should alias the destroy callback on the klass" do
      mock(@callback.klass).alias_method("denormalize_destroy_to_head", "_denormalize_destroy_to_head")
      @callback.send(:alias_destroy_callback)
    end

    it "should not alias the destroy callback if it's already set" do
      @callback.send(:attach)
      dont_allow(@callback.klass).alias_method
      @callback.send(:alias_destroy_callback)
    end
  end
end
