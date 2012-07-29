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
    @callback.send(:define_fields)
    create_models
    @callback.send(callback_name)
  end

  describe "with metadata in advance" do
    def args
      [Person, :head, [:name, :location, :created_at]]
    end

    def create_models
      @head = Head.create(
        :person => @person = Person.create(:name => "Bob",
                                           :created_at => @now = Time.now))
    end

    before do
      Head.class_eval do
        field :person_fields, :type => Hash, :default => nil
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
        define_and_create
      end

      it "should push the fields to the relation" do
        @head.person_fields.should == nil
        run_callback
        @head.person_fields.should == person_fields
      end
    end

    describe "define_destroy_callback" do
      def run_destroy_callback
        @person.send(:_denormalize_destroy_to_head)
      end

      before do
        define_and_create(:define_destroy_callback)
      end

      it "should nillify the fields in the relation" do
        @head.person_fields = { "hi" => "hello" }
        run_destroy_callback
        @head.person_fields.should be_nil
      end

      it "should do nothing if the relation doesn't exist" do
        @head.person = nil
        run_destroy_callback
      end
    end
  end

  describe "to a polymorphic child" do
    def args
      [Person, :nearest_head, [:name, :location, :created_at]]
    end

    def create_models
      @head = Head.create(
        :nearest => @person = Person.create(:name => @name = "Bob",
                                           :created_at => @now = Time.now))
    end

    before do
      Head.class_eval do
        field :nearest_fields, :type => Hash, :default => nil
      end
    end

    describe "define_callback" do
      def nearest_fields
        { "name"=> "Bob",
          "location" => "Paris",
          "created_at"=> @now.to_s(:utc) }
      end

      def run_callback
        @person.send(:_denormalize_to_nearest_head)
      end

      before do
        define_and_create
      end

      it "should push the fields to the relation" do
        @head.nearest_fields.should be_nil
        run_callback
        @head.nearest_fields.should == nearest_fields
      end
    end

    describe "define_destroy_callback" do
      def run_destroy_callback
        @person.send(:_denormalize_destroy_to_nearest_head)
      end

      before do
        define_and_create(:define_destroy_callback)
      end

      it "should nillify the fields in the relation" do
        @head.nearest_fields = { "hi" => "hello" }
        run_destroy_callback
        @head.nearest_fields.should be_nil
      end

      it "should do nothing if the relation doesn't exist" do
        @head.nearest = nil
        run_destroy_callback
      end
    end
  end

  describe "to a polymorphic parent" do
    def args
      [Head, :nearest, [:size]]
    end

    def create_models
      @head = Head.create(
        :nearest => @person = Person.create(:name => @name = "Bob",
                                           :created_at => @now = Time.now))
    end

    before do
      Person.class_eval do
        field :nearest_head_fields, :type => Hash, :default => nil
      end
    end

    describe "define_callback" do
      def nearest_head_fields
        { "size"=> @size }
      end

      def run_callback
        @head.send(:_denormalize_to_nearest)
      end

      before do
        define_and_create
      end

      it "should push the fields to the relation" do
        @person.nearest_head_fields.should be_nil
        run_callback
        @person.nearest_head_fields.should == nearest_head_fields
      end
    end

    describe "define_destroy_callback" do
      def run_destroy_callback
        @head.send(:_denormalize_destroy_to_nearest)
      end

      before do
        define_and_create(:define_destroy_callback)
      end

      it "should nillify the fields in the relation" do
        @person.nearest_head_fields = { "hi" => "hello" }
        run_destroy_callback
        @person.nearest_head_fields.should be_nil
      end

      it "should do nothing if the relation doesn't exist" do
        @person.nearest_head = nil
        run_destroy_callback
      end
    end
  end
end
