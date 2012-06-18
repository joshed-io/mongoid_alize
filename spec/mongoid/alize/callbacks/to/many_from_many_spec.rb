require 'spec_helper'

describe Mongoid::Alize::Callbacks::To::ManyFromMany do
  def klass
    Mongoid::Alize::Callbacks::To::ManyFromMany
  end

  def args
    [Person, :wants, [:name, :created_at]]
  end

  def new_callback
    klass.new(*args)
  end

  def wanted_by_fields
    { "_id" => @person.id,
        "name"=> "Bob",
        "created_at"=> @now.to_s(:utc) }
  end

  def other_wanted_by
    { "_id" => "SomeObjectId" }
  end

  before do
    Head.class_eval do
      field :wanted_by_fields, type: Array
    end

    @head = Head.create(
      :wanted_by => [@person = Person.create(:name => "Bob",
                                      :created_at => @now = Time.now)])
    @person.wants = [@head]

    @callback = new_callback
  end

  describe "#define_callback" do
    before do
      @callback.send(:define_callback)
    end

    def run_callback
      @person.denormalize_to_wants
    end

    it "should push the fields to the relation" do
      @head.wanted_by_fields.should be_nil
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
    before do
      @callback.send(:define_destroy_callback)
    end

    def run_destroy_callback
      @person.denormalize_destroy_to_wants
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
