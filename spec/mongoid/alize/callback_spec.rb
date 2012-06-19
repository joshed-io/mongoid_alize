require 'spec_helper'

class Mongoid::Alize::SpecCallback < Mongoid::Alize::Callback
  def attach
    klass.class_eval do
      def denormalize_spec_person
      end
    end
  end

  def direction
    "spec"
  end
end

describe Mongoid::Alize::Callback do
  def klass
    Mongoid::Alize::SpecCallback
  end

  def args
    [Head, :person, [:name, :created_at]]
  end

  def new_callback
    klass.new(*args)
  end

  describe "initialize" do
    it "should assign class attributes" do
      callback = new_callback
      callback.klass.should == Head
      callback.relation.should == :person
      callback.inverse_klass = Person
      callback.inverse_relation = :head
      callback.fields.should == [:name, :created_at]
    end
  end

  describe "with callback " do
    before do
      @callback = new_callback
    end

    describe "#alias_callback" do
      it "should alias the callback on the klass" do
        mock(@callback.klass).alias_method("denormalize_spec_person", "_denormalize_spec_person")
        @callback.send(:alias_callback)
      end

      it "should not alias the callback if it's already set" do
        @callback.send(:attach)
        dont_allow(@callback.klass).alias_method
        @callback.send(:alias_callback)
      end
    end
  end
end

