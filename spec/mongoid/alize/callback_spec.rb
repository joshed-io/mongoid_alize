require 'spec_helper'

describe Mongoid::Alize::Callback do
  def klass
    Mongoid::Alize::Callback
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
end

