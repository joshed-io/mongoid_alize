require 'spec_helper'

describe Mongoid::Alize::Callbacks::From::Many do
  def klass
    Mongoid::Alize::Callbacks::From::Many
  end

  def args
    [Head, :wanted_by, [:name, :location, :created_at]]
  end

  def new_callback
    klass.new(*args)
  end

  describe "#define_mongoid_field" do
    it "should define an Array called {relation}_fields" do
      callback = new_callback
      callback.send(:define_mongoid_field)
      Head.fields["wanted_by_fields"].type.should == Array
    end

    it "should default the field to empty" do
      callback = new_callback
      callback.send(:define_mongoid_field)
      Head.new.wanted_by_fields.should == []
    end

    it "should raise an already defined field error if the field already exists" do
      Head.class_eval do
        field :wanted_by_fields
      end
      callback = new_callback
      expect {
        callback.send(:define_mongoid_field)
      }.to raise_error(Mongoid::Alize::Errors::AlreadyDefinedField,
                       "wanted_by_fields is already defined on the Head model.")
    end
  end

  describe "the defined callback" do
    def run_callback
      @head.send(:_denormalize_from_wanted_by)
    end

    def bob_fields
      { "_id" => @person.id,
        "name"=> "Bob",
        "location" => "Paris",
        "created_at" => @now }
    end

    before do
      @head = Head.create
      @person = Person.create(:name => "Bob")

      @head.relations["wanted_by"].should be_stores_foreign_key
    end

    describe "valid fields" do
      before do
        @callback = new_callback
        @callback.send(:define_mongoid_field)
        @callback.send(:define_denorm_attrs)
        @callback.send(:define_callback)
      end

      it "should set fields from a changed relation" do
        @head.wanted_by = [@person]
        run_callback
        @head.wanted_by_fields.should == [bob_fields]
      end

      it "should still set fields there are no changes" do
        @head.should_not be_wanted_by_ids_changed
        mock.proxy(@head).wanted_by
        run_callback
      end
    end

    describe "with a field that doesn't exist" do
      before do
        @callback = klass.new(Head, :wanted_by, [:notreal])
        @callback.send(:define_mongoid_field)
        @callback.send(:define_callback)
      end

      it "should raise a no method error" do
        @head.wanted_by = [@person]
        @head.wanted_by_fields.should be_nil
        expect {
          run_callback
        }.to raise_error NoMethodError
      end
    end
  end

  describe "in a one to many case" do
    def run_callback
      @head.send(:_denormalize_from_sees)
    end

    before do
      @head = Head.create
      @person = Person.create(:name => "Bob")

      @callback = klass.new(Head, :sees, [:name])
      @callback.send(:define_mongoid_field)
      @callback.send(:define_denorm_attrs)
      @callback.send(:define_callback)

      @head.relations["sees"].should_not be_stores_foreign_key
    end

    it "should field from a changed relation" do
      @head.sees << @person
      run_callback
      @head.sees_fields.should == [{
        "_id" => @person.id,
        "name" => "Bob"
      }]
    end
  end
end
