require 'spec_helper'

describe Mongoid::Alize::Callbacks::To::OneFromMany do
  def klass
    Mongoid::Alize::Callbacks::To::OneFromMany
  end

  def args
    [Person, :heads, [:name, :location, :created_at]]
  end

  def new_callback
    klass.new(*args)
  end

  def create_models
    @head = Head.create(
      :captor => @person = Person.create(:name => "Bob", :created_at => @now = Time.now))
    @person.heads = [@head]
  end

  before do
    Head.class_eval do
      field :captor_fields, :type => Hash, :default => {}
    end
  end

  describe "#define_callback" do
    def captor_fields
      { "name"=> "Bob",
        "location" => "Paris",
        "created_at"=> @now.to_s(:utc) }
    end

    def run_callback
      @person.send(:_denormalize_to_heads)
    end

    before do
      @callback = new_callback
      @callback.send(:define_fields)
      create_models
      @callback.send(:define_callback)
    end

    it "should push the fields to the relation" do
      @head.captor_fields.should == {}
      run_callback
      @head.captor_fields.should == captor_fields
    end
  end

  describe "#define_destroy_callback" do
    before do
      @callback = new_callback
      @callback.send(:define_fields)
      create_models
      @callback.send(:define_destroy_callback)
    end

    def run_destroy_callback
      @person.send(:_denormalize_destroy_to_heads)
    end

    it "should remove the fields from the relation" do
      @head.captor_fields = { "hi" => "hello" }
      run_destroy_callback
      @head.captor_fields.should == {}
    end

    it "should do nothing if the relation doesn't exist" do
      @head.captor = nil
      run_destroy_callback
    end
  end
end
