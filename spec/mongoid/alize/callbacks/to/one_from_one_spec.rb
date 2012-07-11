require 'spec_helper'

describe Mongoid::Alize::Callbacks::To::OneFromOne do
  def klass
    Mongoid::Alize::Callbacks::To::OneFromOne
  end

  def args
    [Person, :head, [:name, :location, :created_at]]
  end

  def new_callback
    klass.new(*args)
  end

  def create_models
    @head = Head.create(
      :person => @person = Person.create(:name => "Bob",
                                         :created_at => @now = Time.now))
  end

  before do
    Head.class_eval do
      field :person_fields, :type => Hash, :default => {}
    end
  end

  describe "define_callback" do
    def person_fields
      { "name"=> "Bob",
        "location" => "Paris",
        "created_at"=> @now.to_s(:utc) }
    end

    def run_callback
      @person.send(:_denormalize_to_head)
    end

    before do
      @callback = new_callback
      @callback.send(:define_fields)
      create_models
      @callback.send(:define_callback)
    end

    it "should push the fields to the relation" do
      @head.person_fields.should == {}
      run_callback
      @head.person_fields.should == person_fields
    end
  end

  describe "define_destroy_callback" do
    before do
      @callback = new_callback
      @callback.send(:define_fields)
      create_models
      @callback.send(:define_destroy_callback)
    end

    def run_destroy_callback
      @person.send(:_denormalize_destroy_to_head)
    end

    it "should nillify the fields in the relation" do
      @head.person_fields = { "hi" => "hello" }
      run_destroy_callback
      @head.person_fields.should == {}
    end

    it "should do nothing if the relation doesn't exist" do
      @head.person = nil
      run_destroy_callback
    end
  end
end
