require 'spec_helper'

describe Mongoid::Alize::ToCallback do
  def klass
    Mongoid::Alize::ToCallback
  end

  def args
    [Person, :wants, [:name, :location, :created_at]]
  end

  def new_callback
    klass.new(*args)
  end

  def wanted_by_fields
    { "_id" => @person.id,
        "name" => "Bob",
        "location" => "Paris",
        "created_at" => @now }
  end

  def other_wanted_by
    { "_id" => "SomeObjectId" }
  end

  def create_models
    @head = Head.create(
      :wanted_by => [@person = Person.create(:name => "Bob")])
    @person.wants = [@head]
  end

  before do
    Head.class_eval do
      field :wanted_by_fields, type: Array, :default => []
    end
  end

  describe "#define_callback" do
    def run_callback
      @person.send(:_denormalize_to_wants)
    end

    before do
      @callback = new_callback
      @callback.send(:define_denorm_attrs)
      create_models
      @callback.send(:define_callback)
    end

    it "should push the fields to the relation" do
      @head.wanted_by_fields.should == []
      run_callback
      @head.wanted_by_fields.should == [wanted_by_fields]
    end

    it "should pull first any existing array entries matching the _id" do
      @head.wanted_by_fields = [other_wanted_by]
      @head.save!

      run_callback
      run_callback

      # to make sure persisted in both DB and updated in memory
      @head.wanted_by_fields.should == [other_wanted_by, wanted_by_fields]
      @head.reload
      @head.wanted_by_fields.should == [other_wanted_by, wanted_by_fields]
    end
  end

  describe "#define_destroy_callback" do
    def run_destroy_callback
      @person.send(:_denormalize_destroy_to_wants)
    end

    before do
      @callback = new_callback
      @callback.send(:define_denorm_attrs)
      create_models
      @callback.send(:define_destroy_callback)
    end

    it "should pull first any existing array entries matching the _id" do
      @head.wanted_by_fields = [wanted_by_fields, other_wanted_by]
      @head.save!

      run_destroy_callback

      # to make sure persisted in both DB and updated in memory
      @head.wanted_by_fields.should == [other_wanted_by]
      @head.reload
      @head.wanted_by_fields.should == [other_wanted_by]
    end
  end
end
