require 'spec_helper'

describe Mongoid::Alize::Callbacks::From::One do
  def klass
    Mongoid::Alize::Callbacks::From::One
  end

  def args
    [Head, :person, [:name, :created_at]]
  end

  def new_callback
    klass.new(*args)
  end

  describe "#define_fields" do
    it "should add properly typed, prefixed fields from the relation" do
      callback = new_callback
      callback.send(:define_fields)
      Head.fields["person_name"].type.should == String
      Head.fields["person_created_at"].type.should == Time
    end

    it "should raise an InvalidField error for a field that's not defined" do
      callback = klass.new(Head, :person, [:date_of_birth])
      expect {
        callback.send(:define_fields)
      }.to raise_error(Mongoid::Alize::Errors::InvalidField,
                       "date_of_birth does not exist on the Person model.")
    end
  end

  describe "the defined callback" do
    def run_callback
      @head.denormalize_from_person
    end

    before do
      @head = Head.create(
        :person => @person = Person.create(:name => @name = "Bob",
                                           :created_at => @now = Time.now))
      @callback = new_callback
      @callback.send(:define_fields)
      @callback.send(:define_callback)
    end

    it "should set pull fields from the relation" do
      @head.person_name.should be_nil
      @head.person_created_at.should be_nil
      run_callback
      @head.person_name.should == @name
      @head.person_created_at.to_i.should == @now.to_i
    end

    it "should assign nil values if the relation is nil" do
      @head.person_name = "not nil"
      @head.person_created_at = Time.now
      @head.person = nil
      run_callback
      @head.person_name.should be_nil
      @head.person_created_at.should be_nil
    end
  end
end
