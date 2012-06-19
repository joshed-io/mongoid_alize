require 'spec_helper'

describe Mongoid::Alize::Callbacks::To::ManyFromOne do
  def klass
    Mongoid::Alize::Callbacks::To::ManyFromOne
  end

  def args
    [Person, :seen_by, [:name, :location, :created_at]]
  end

  def new_callback
    klass.new(*args)
  end

  def sees_fields
    { "_id" => @person.id,
      "name"=> "Bob",
      "location" => "Paris",
      "created_at"=> @now.to_s(:utc) }
  end

  def other_see
    { "_id" => "SomeObjectId" }
  end

  before do
    Head.class_eval do
      field :sees_fields, :type => Array
    end

    @head = Head.create(
      :sees => [@person = Person.create(:name => "Bob",
                                      :created_at => @now = Time.now)])
    @person.seen_by = @head
    @callback = new_callback
  end

  describe "#define_callback" do
    before do
      @callback.send(:define_callback)
    end

    def run_callback
      @person.denormalize_to_seen_by
    end

    it "should push the fields to the relation" do
      @head.sees_fields.should be_nil
      run_callback
      @head.sees_fields.should == [sees_fields]
    end

    it "should pull first any existing array entries matching the _id" do
      @head.sees_fields = [other_see]
      @head.save!

      run_callback
      run_callback

      # to make sure persisted in both DB and updated in memory
      @head.sees_fields.should == [other_see, sees_fields]
      @head.reload
      @head.sees_fields.should == [other_see, sees_fields]
    end

    it "should do nothing if the inverse is nil" do
      @person.seen_by = nil
      run_callback
    end
  end

  describe "#define_destroy_callback" do
    before do
      @callback.send(:define_destroy_callback)
    end

    def run_destroy_callback
      @person.denormalize_destroy_to_seen_by
    end

    it "should pull first any existing array entries matching the _id" do
      @head.sees_fields = [sees_fields, other_see]
      @head.save!

      run_destroy_callback

      # to make sure persisted in both DB and updated in memory
      @head.sees_fields.should == [other_see]
      @head.reload
      @head.sees_fields.should == [other_see]
    end

    it "should do nothing if the inverse is nil" do
      @person.seen_by = nil
      run_destroy_callback
    end
  end
end
