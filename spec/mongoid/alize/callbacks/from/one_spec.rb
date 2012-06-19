require 'spec_helper'

describe Mongoid::Alize::Callbacks::From::One do
  def klass
    Mongoid::Alize::Callbacks::From::One
  end

  def args
    [Head, :person, [:name, :location, :created_at]]
  end

  def new_callback
    klass.new(*args)
  end

  describe "#define_fields" do
    it "should add properly typed, prefixed fields from the relation" do
      callback = klass.new(Head, :person, [:name, :created_at])
      callback.send(:define_fields)
      Head.fields["person_name"].type.should == String
      Head.fields["person_created_at"].type.should == Time
    end

    it "should define as a string field that's not defined" do
      callback = klass.new(Head, :person, [:location])
      callback.send(:define_fields)
      Head.fields["person_location"].type.should == String
    end

    it "should not add the field if the field already exists" do
      Head.class_eval do
        field :person_name
      end
      callback = klass.new(Head, :person, [:name])
      dont_allow(Head).field
      callback.send(:define_fields)
    end

    it "should not add the field if it already exists b/c of another relation" do
      callback = klass.new(Head, :person, [:id])
      dont_allow(Head).field
      callback.send(:define_fields)
    end

    it "should allow the id and type of the inverse to be denormalized without an extra _" do
      callback = klass.new(Person, :head, [:id, :type])
      callback.send(:define_fields)
      Person.fields["head_id"].type.should == BSON::ObjectId
      Person.fields["head_type"].type.should == String
    end
  end

  describe "the defined callback" do
    def run_callback
      @head.send(:_denormalize_from_person)
    end

    before do
      @head = Head.create
      @person = Person.create(:name => @name = "Bob",
                              :created_at => @now = Time.now)

      @callback = new_callback
      @callback.send(:define_fields)
      @callback.send(:define_callback)

      @head.person_name.should be_nil
      @head.person_created_at.should be_nil
    end

    it "should set fields from the relation" do
      @head.person = @person
      run_callback
      @head.person_name.should == @name
      @head.person_created_at.to_i.should == @now.to_i
      @head.person_location.should == "Paris"
    end

    it "should assign nil values if the relation is nil" do
      @head.person_name = "not nil"
      @head.person_created_at = Time.now
      @head.person = nil
      run_callback
      @head.person_name.should be_nil
      @head.person_created_at.should be_nil
    end

    describe "on save" do
      before do
        @head.person = @person
        @head.save!
        @person_2 = Person.create(:name => "Bill")
      end

      it "should run if the relation has changed" do
        @head.person = @person_2
        run_callback
        @head.person_name.should == "Bill"
      end

      it "should run if the relation key is nil" do
        @head.person = nil
        mock.proxy(@head).person
        run_callback
      end

      it "should not run if the relation has not changed" do
        @head.person = @person_2
        @head.save!
        dont_allow(@head).person
        run_callback
      end
    end
  end

  describe "the defined callback when denormalizing on the has_one side" do
    def run_callback
      @person.send(:_denormalize_from_head)
    end

    before do
      @person = Person.create
      @head = Head.create(:size => 5)

      @callback = klass.new(Person, :head, [:size])
      @callback.send(:define_fields)
      @callback.send(:define_callback)

      @person.head_size.should be_nil
    end

    describe "on save" do
      before do
        @person.head = @head
        @person.save!
        @head_2 = Head.create(:size => 10)
      end

      it "should run if the relation has changed" do
        @person.head = @head_2
        run_callback
        @person.head_size.should == 10
      end

      it "should run if the relation key is nil" do
        @person.head = nil
        mock.proxy(@person).head
        run_callback
      end

      it "should run even if the relation has not changed" do
        @person.head = @head_2
        @person.save!
        mock.proxy(@person).head
        run_callback
      end
    end
  end
end
