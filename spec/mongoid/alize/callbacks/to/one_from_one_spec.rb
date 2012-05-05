require 'spec_helper'

describe Mongoid::Alize::Callbacks::To::OneFromOne do
  def klass
    Mongoid::Alize::Callbacks::To::OneFromOne
  end

  def args
    [Person, :head, [:name, :created_at]]
  end

  def new_unit
    klass.new(*args)
  end

  before do
    Head.class_eval do
      field :person_name, :type => String
      field :person_created_at, :type => Time
    end

    @head = Head.create(
      :person => @person = Person.create(:name => "Bob",
                                      :created_at => @now = Time.now))

    @unit = new_unit
  end

  describe "define_callback" do
    before do
      @unit.send(:define_callback)
    end

    def run_callback
      @person.send(callback_name)
    end

    def callback_name
      "denormalize_to_head"
    end

    it "should push the fields to the relation" do
      @head.person_name.should be_nil
      @head.person_created_at.should be_nil
      run_callback
      @head.person_name.should == "Bob"
      @head.person_created_at.to_i.should == @now.to_i
    end

    it "should do nothing if the relation doesn't exist" do
      @head.person = nil
      run_callback
    end
  end

  describe "define_destroy_callback" do
    before do
      @unit.send(:define_destroy_callback)
    end

    def run_destroy_callback
      @person.send(destroy_callback_name)
    end

    def destroy_callback_name
      "denormalize_destroy_to_head"
    end

    it "should nillify the fields in the relation" do
      @head.person_name = "Chuck"
      @head.person_created_at = Time.now
      run_destroy_callback
      @head.person_name.should be_nil
      @head.person_created_at.should be_nil
    end

    it "should do nothing if the relation doesn't exist" do
      @head.person = nil
      run_destroy_callback
    end
  end
end
