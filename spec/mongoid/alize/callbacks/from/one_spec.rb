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

  describe "#define_mongoid_field" do
    describe "with an array of fields" do
      it "should add a field generated from %{relation}_fields" do
        callback = new_callback
        callback.send(:define_mongoid_field)
        Head.fields["person_fields"].type.should == Hash
      end

      it "should default the field to empty" do
        callback = new_callback
        callback.send(:define_mongoid_field)
        Head.new.person_fields.should == {}
      end

      it "should raise an already defined field error if the field already exists" do
        Head.class_eval do
          field :person_fields
        end
        callback = new_callback
        expect {
          callback.send(:define_mongoid_field)
        }.to raise_error(Mongoid::Alize::Errors::AlreadyDefinedField,
                         "person_fields is already defined on the Head model.")
      end
    end
  end

  describe "the defined callback" do
    def run_callback(force=false)
      @head.send(:_denormalize_from_person, force)
    end

    def person_fields
      { "name"=> "Bob",
        "location" => "Paris",
        "created_at"=> @now }
    end

    def create_models
      @head = Head.create
      @person = Person.create(:name => @name = "Bob")
    end

    before do
      @callback = new_callback
      @callback.send(:define_mongoid_field)
      @callback.send(:define_denorm_attrs)
      create_models
      @callback.send(:define_callback)
    end

    it "should set fields from a changed relation" do
      @head.person = @person
      @head.should be_person_id_changed
      run_callback
      @head.person_fields.should == person_fields
    end

    it "should set no fields from a nil relation" do
      @head.person = @person
      @head.save!
      @head.person = nil
      @head.should be_person_id_changed
      run_callback
      @head.person_fields.should == nil
    end

    it "should not run if the relation has not changed" do
      @head.relations["person"].should be_stores_foreign_key
      @head.should_not be_person_id_changed
      dont_allow(@head).person
      run_callback
    end

    it "should still run if the relation has not changed but force is passed" do
      @head.should_not be_person_id_changed
      mock.proxy(@head).person
      run_callback(true)
    end

    it "should still run if the relation has not changed but force_denormalization is set on the class" do
      @head.should_not be_person_id_changed
      @head.force_denormalization = true
      mock.proxy(@head).person
      run_callback
    end
  end

  describe "the defined callback when denormalizing on the has_one side" do
    def run_callback
      @person.send(:_denormalize_from_head)
    end

    before do
      @callback = klass.new(Person, :head, [:size])
      @callback.send(:define_mongoid_field)
      @callback.send(:define_denorm_attrs)

      @person = Person.create
      @head = Head.create(:size => 5)

      @callback.send(:define_callback)
      @person.relations["head"].should_not be_stores_foreign_key
    end

    it "should set values from a changed relation" do
      @person.head = @head
      run_callback
      @person.head_fields.should == {
        "size" => 5
      }
    end

    it "should set values from a a nil relation" do
      @person.head = @head
      @person.save!
      @person.head = nil
      run_callback
      @person.head_fields.should be_nil
    end

    it "should run even if the relation has not changed" do
      mock.proxy(@person).head
      run_callback
    end
  end
end
