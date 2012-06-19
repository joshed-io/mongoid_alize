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

  describe "#define_fields" do
    it "should define an Array called {relation}_fields" do
      callback = new_callback
      callback.send(:define_fields)
      Head.fields["wanted_by_fields"].type.should == Array
    end

    it "should default the field to empty" do
      callback = new_callback
      callback.send(:define_fields)
      Head.new.wanted_by_fields.should == []
    end

    it "should raise an already defined field error if the field already exists" do
      Head.class_eval do
        field :wanted_by_fields
      end
      callback = new_callback
      expect {
        callback.send(:define_fields)
      }.to raise_error(Mongoid::Alize::Errors::AlreadyDefinedField,
                       "wanted_by_fields is already defined on the Head model.")
    end
  end

  describe "the defined callback" do
    def run_callback
      @head.denormalize_from_wanted_by
    end

    before do
      @head = Head.create(
        :wanted_by => [@person = Person.create(:name => "Bob",
                                        :created_at => @now = Time.now)])

    end

    describe "valid fields" do
      before do
        @callback = new_callback
        @callback.send(:define_fields)
        @callback.send(:define_callback)
      end

      it "should pull the fields from the relation" do
        @head.wanted_by_fields.should be_nil
        run_callback
        @head.wanted_by_fields.should == [{
          "_id" => @person.id,
          "name"=> "Bob",
          "location" => "Paris",
          "created_at"=> @now.to_s(:utc)
        }]
      end
    end

    describe "with a field that doesn't exist" do
      before do
        @callback = klass.new(Head, :wanted_by, [:notreal])
        @callback.send(:define_fields)
        @callback.send(:define_callback)
      end

      it "should raise a no method error" do
        @head.wanted_by_fields.should be_nil
        expect {
          run_callback
        }.to raise_error NoMethodError
      end
    end
  end
end
