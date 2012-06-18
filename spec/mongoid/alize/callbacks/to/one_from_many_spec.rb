require 'spec_helper'

describe Mongoid::Alize::Callbacks::To::OneFromMany do
  def klass
    Mongoid::Alize::Callbacks::To::OneFromMany
  end

  def args
    [Person, :heads, [:name, :created_at]]
  end

  def new_callback
    klass.new(*args)
  end

  before do
    Head.class_eval do
      field :captor_name, :type => String
      field :captor_created_at, :type => Time
    end

    @head = Head.create(
      :captor => @person = Person.create(:name => "Bob",
                                         :created_at => @now = Time.now))
    @person.heads = [@head]

    @callback = new_callback
  end

  describe "#define_callback" do
    before do
      @callback.send(:define_callback)
    end

    def run_callback
      @person.denormalize_to_heads
    end

    it "should push the fields to the relation" do
      @head.captor_name.should be_nil
      @head.captor_created_at.should be_nil
      run_callback
      @head.captor_name.should == "Bob"
      @head.captor_created_at.to_i.should == @now.to_i
    end
  end

  describe "#define_destroy_callback" do
    def run_destroy_callback
      @person.denormalize_destroy_to_heads
    end

    before do
      @callback.send(:define_destroy_callback)
    end

    it "should remove the fields from the relation" do
      @head.captor_name.should be_nil
      @head.captor_created_at.should be_nil
      run_destroy_callback
      @head.captor_name.should be_nil
      @head.captor_created_at.should be_nil
    end
  end
end
