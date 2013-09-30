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
    @callback.send(:define_denorm_attrs)
    create_models
    @callback.send(callback_name)
  end

  describe "with metadata in advance" do
    def create_models
      @head = Head.create(
        :captor => @person = Person.create(:name => "Bob"))
      @person.heads = [@head]
    end

    def args
      [Person, :heads, [:name, :location, :created_at]]
    end

    before do
      Head.class_eval do
        field :captor_fields, :type => Hash, :default => nil
      end
    end

    describe "#define_callback" do
      def captor_fields
        { "name"=> "Bob",
          "location" => "Paris",
          "created_at"=> @now }
      end

      def run_callback
        @person.send(:_denormalize_to_heads)
      end

      before do
        define_and_create
      end

      it "should push the fields to the relation" do
        @head.captor_fields.should be_nil
        run_callback
        @head.captor_fields.should == captor_fields
      end
    end

    describe "#define_destroy_callback" do
      def run_destroy_callback
        @person.send(:_denormalize_destroy_to_heads)
      end

      before do
        define_and_create(:define_destroy_callback)
      end

      it "should remove the fields from the relation" do
        @head.captor_fields = { "hi" => "hello" }
        run_destroy_callback
        @head.captor_fields.should be_nil
      end

      it "should do nothing if the relation doesn't exist" do
        @head.captor = nil
        run_destroy_callback
      end
    end
  end

  describe "with a polymorphic relationship" do
    def create_models
      @person = Person.create(:name => "Bob", :created_at => @now = Time.now)
      @head = Head.create(:size => @size = 10)
      @person.above = @head
    end

    def args
      [Head, :below_people, [:size]]
    end

    before do
      Person.class_eval do
        field :above_fields, :type => Hash, :default => nil
      end
    end

    describe "#define_callback" do
      def above_fields
        { "size"=> @size }
      end

      def run_callback
        @head.send(:_denormalize_to_below_people)
      end

      before do
        define_and_create
      end

      it "should push the fields to the relation" do
        @person.above_fields.should be_nil
        run_callback
        @person.above_fields.should == above_fields
      end
    end

    describe "#define_destroy_callback" do
      before do
        define_and_create(:define_destroy_callback)
      end

      def run_destroy_callback
        @head.send(:_denormalize_destroy_to_below_people)
      end

      it "should remove the fields from the relation" do
        @person.above_fields = { "hi" => "hello" }
        run_destroy_callback
        @person.above_fields.should be_nil
      end

      it "should do nothing if the relation doesn't exist" do
        @person.above = nil
        run_destroy_callback
      end
    end
  end
end
