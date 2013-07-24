require 'spec_helper'

describe Mongoid::Alize::ToCallback do
  def klass
    Mongoid::Alize::ToCallback
  end

  def new_callback
    klass.new(*args)
  end

  def define_and_create(callback_name=:define_callback)
    @callback = new_callback
    @callback.send(:define_fields_method)
    create_models
    @callback.send(callback_name)
  end

  describe "with metadata in advance" do
    def create_models
      @head = Head.create(
        :sees => [@person = Person.create(:name => "Bob")])
      @person.seen_by = @head
    end

    def args
      [Person, :seen_by, [:name, :location, :created_at]]
    end

    def sees_fields
      { "_id" => @person.id,
        "name"=> "Bob",
        "location" => "Paris",
        "created_at"=> @now }
    end

    def other_see
      { "_id" => "SomeObjectId" }
    end

    before do
      Head.class_eval do
        field :sees_fields, :type => Array, :default => []
      end
    end

    describe "#define_callback" do
      def run_callback
        @person.send(:_denormalize_to_seen_by)
      end

      before do
        define_and_create
      end

      it "should push the fields to the relation" do
        @head.sees_fields.should == []
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
      def run_destroy_callback
        @person.send(:_denormalize_destroy_to_seen_by)
      end

      before do
        define_and_create(:define_destroy_callback)
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

  describe "with a polymorphic model" do
    def create_models
      @person = Person.create(:name => @name = "Bob", :created_at => @now = Time.now)
      @head = Head.create(:size => @size = 10)
      @person.above = @head
    end

    def args
      [Person, :above, [:name]]
    end

    def below_people_fields
      { "_id" => @person.id,
        "name"=> @name }
    end

    def other_below_people
      { "_id" => "SomeObjectId" }
    end

    before do
      Head.class_eval do
        field :below_people_fields, :type => Array, :default => []
      end
    end

    describe "#define_callback" do
      def run_callback
        @person.send(:_denormalize_to_above)
      end

      before do
        define_and_create
      end

      it "should push the fields to the relation" do
        @head.below_people_fields.should == []
        run_callback
        @head.below_people_fields.should == [below_people_fields]
      end

      it "should pull first any existing array entries matching the _id" do
        @head.below_people_fields = [other_below_people]
        @head.save!

        run_callback
        run_callback

        # to make sure persisted in both DB and updated in memory
        @head.below_people_fields.should == [other_below_people, below_people_fields]
        @head.reload
        @head.below_people_fields.should == [other_below_people, below_people_fields]
      end

      it "should do nothing if the inverse is nil" do
        @person.above = nil
        run_callback
      end
    end

    describe "#define_destroy_callback" do
      def run_destroy_callback
        @person.send(:_denormalize_destroy_to_above)
      end

      before do
        define_and_create(:define_destroy_callback)
      end

      it "should pull first any existing array entries matching the _id" do
        @head.below_people_fields = [below_people_fields, other_below_people]
        @head.save!

        run_destroy_callback

        # to make sure persisted in both DB and updated in memory
        @head.below_people_fields.should == [other_below_people]
        @head.reload
        @head.below_people_fields.should == [other_below_people]
      end

      it "should do nothing if the inverse is nil" do
        @person.above = nil
        run_destroy_callback
      end
    end
  end
end
