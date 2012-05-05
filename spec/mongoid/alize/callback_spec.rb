require 'spec_helper'

describe Mongoid::Alize::Callback do
  def klass
    Mongoid::Alize::Callback
  end

  def args
    [Head, :person, [:name, :created_at]]
  end

  def new_unit
    klass.new(*args)
  end

  describe "initialize" do
    it "should assign class attributes" do
      unit = new_unit
      unit.klass.should == Head
      unit.relation.should == :person
      unit.inverse_klass = Person
      unit.inverse_relation = :head
      unit.fields.should == [:name, :created_at]
    end
  end
end

