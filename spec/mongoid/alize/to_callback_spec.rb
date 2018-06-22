require 'spec_helper'

describe Mongoid::Alize::ToCallback do
  def klass
    Mongoid::Alize::ToCallback
  end

  def args
    [Person, :head, [:name]]
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

  before do
    @callback = new_callback
  end

  describe "names" do
    it "should assign a destroy callback name" do
      @callback.destroy_callback_name.should == :_denormalize_destroy_to_head
    end

    it "should assign an aliased destroy callback name" do
      @callback.aliased_destroy_callback_name.should == :denormalize_destroy_to_head
    end

    it "should assign a prefixed name from the inverse if present" do
      @callback.inverse_klass.should == Head
      @callback.inverse_relation.should == :person
      @callback.prefixed_name.should == ":person_fields"
    end

    it "should compute the name on the fly if the inverse is not present" do
      @callback = klass.new(Head, :nearest, [:name])
      @callback.inverse_klass.should be_nil
      @callback.inverse_relation.should be_nil
      @callback.prefixed_name.should =~ /relation/
    end
  end

  describe "#define_denorm_attrs" do
    it "should define the denorm attrs method" do
      mock(@callback).define_denorm_attrs
      @callback.send(:define_denorm_attrs)
    end
  end

  describe "#set_callback" do
    it "should set a callback on the klass" do
      mock(@callback.klass).set_callback(:save, :after, :denormalize_to_head)
      @callback.send(:set_callback)
    end

    it "should not set the callback if it's already set" do
      @callback.send(:attach)
      dont_allow(@callback.klass).set_callback
      @callback.send(:set_callback)
    end
  end

  describe "#set_destroy_callback" do
    it "should set a destroy callback on the klass" do
      mock(@callback.klass).set_callback(:destroy, :after, :denormalize_destroy_to_head)
      @callback.send(:set_destroy_callback)
    end

    it "should not set the destroy callback if it's already set" do
      @callback.send(:attach)
      dont_allow(@callback.klass).set_callback
      @callback.send(:set_destroy_callback)
    end
  end

  describe "#alias_destroy_callback" do
    it "should alias the destroy callback on the klass" do
      mock(@callback.klass).alias_method(:denormalize_destroy_to_head, :_denormalize_destroy_to_head)
      mock(@callback.klass).public(:denormalize_destroy_to_head)
      @callback.send(:alias_destroy_callback)
    end

    it "should not alias the destroy callback if it's already set" do
      @callback.send(:attach)
      dont_allow(@callback.klass).alias_method
      @callback.send(:alias_destroy_callback)
    end
  end

  describe "not modifying frozen hashes" do
    def create_models
      @person = Person.create!(:name => @name = "George")
      @head = Head.create(:person => @person)
    end

    def person_fields
      { :name => @name }
    end

    before do
      Head.class_eval do
        field :person_fields, :type => Hash, :default => {}
      end
      define_and_create(:define_destroy_callback)
    end

    describe "#define_callback" do
      def run_callback
        @person.send(:_denormalize_to_head)
      end

      before do
        define_and_create(:define_callback)
      end

      it "should not modify object frozen for deletion" do
        @head.destroy
        run_callback
        @head.person_fields.should == {}
      end
    end

    describe "#define_destroy_callback" do
      def run_callback
        @person.send(:_denormalize_destroy_to_head)
      end

      it "should not modify object frozen for deletion" do
        @head.person_fields = person_fields
        @head.destroy
        run_callback
        @head.person_fields.should == person_fields
      end
    end
  end
end
