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
      callback.inverse_metadata.should == Person.relations["head"]
      callback.denorm_attrs.should == [:name, :created_at]
    end

    it "should not set inverses for the child in a polymorphic association" do
      callback = klass.new(Head, :nearest, [:size])
      callback.inverse_klass.should be_nil
      callback.inverse_relation.should be_nil
    end

    it "should set inverses for the parent in a polymorphic association" do
      callback = klass.new(Person, :nearest_head, [:size])
      callback.inverse_klass.should == Head
      callback.inverse_relation.should == :nearest
    end
  end

  describe "with callback" do
    before do
      @callback = new_callback
    end

    describe "#alias_callback" do
      it "should alias the callback on the klass and make it public" do
        mock(@callback.klass).alias_method("denormalize_spec_person", "_denormalize_spec_person")
        mock(@callback.klass).public("denormalize_spec_person")
        @callback.send(:alias_callback)
      end

      it "should not alias the callback if it's already set" do
        @callback.send(:attach)
        dont_allow(@callback.klass).alias_method
        @callback.send(:alias_callback)
      end
    end
  end

  describe "name helpers" do
    before do
      @callback = new_callback
    end

    it "should have a callback name" do
      @callback.callback_name.should == "_denormalize_spec_person"
    end

    it "should have aliased callback name" do
      @callback.aliased_callback_name.should == "denormalize_spec_person"
    end

    it "should add _attrs to the callback name" do
      @callback.denorm_attrs_name.should == "_denormalize_spec_person_attrs"
    end
  end

  describe "#define_denorm_attrs" do
    def define_denorm_attrs
      @callback.send(:define_denorm_attrs)
    end

    describe "when denorm_attrs is an array" do
      before do
        @callback = new_callback
      end

      it "should return the denorm_attrs w/ to_s applied" do
        define_denorm_attrs
        @head = Head.new
        @head.send("_denormalize_spec_person_attrs", nil).should == ["name", "created_at"]
      end
    end

    describe "when denorm_attrs is a proc" do
      before do
        @callback = klass.new(Head, :person, lambda { |inverse| [:name, :created_at] })
      end

      it "should return the denorm_attrs w/ to_s applied" do
        define_denorm_attrs
        @head = Head.new
        @head.send("_denormalize_spec_person_attrs", Person.new).should == ["name", "created_at"]
      end
    end
  end
end

