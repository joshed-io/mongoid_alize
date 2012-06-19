require 'spec_helper'

describe Mongoid::Alize do
  def person_fields
    [:name, :location]
  end

  def head_fields
    [:size]
  end

  before do
    @now = Time.now
    stub(Time).now { @now }
    @head = Head.new(:size => @size = 10, created_at: @now)
    @person = Person.new(:name => @name = "Bob", created_at: @now)
  end

  describe "one-to-one" do
    describe "from belongs_to side" do
      before do
        Head.send(:alize, :person, *person_fields)
        @head.person = @person
      end

      def assert_head
        @head.person_name.should == @name
        @head.person_location.should == "Paris"
      end

      it "should pull data from person on create" do
        @head.save!
        assert_head
      end

      it "should pull data from a changed person on save" do
        @head.save!
        @head.person = Person.create(:name => @name = "Bill")
        @head.save!
        assert_head
      end

      it "should not pull data from an unchanged person on save" do
        @head.save!
        @head.person_name = "Cowboy"
        @head.save!
        @head.person_name.should == "Cowboy"
      end

      it "should push data to head" do
        @person.update_attributes!(:name => @name = "Bill")
        assert_head
      end

      it "should nillify person fields in head when person is destroyed" do
        @head.update_attributes!(:person_name => "Old Gregg")
        @person.destroy
        @head.person_name.should be_nil
        @head.person_location.should be_nil
      end
    end

    describe "from has_one side" do
      before do
        Person.send(:alize, :head, *head_fields)
        @person.head = @head
      end

      def assert_person
        @person.head_size.should == @size
      end

      it "should pull data from head on create" do
        @person.save!
        assert_person
      end

      it "should pull data from head on save" do
        @person.save!
        @person.head = Head.create(:size => @size = 18)
        @person.save!
        assert_person
      end

      it "should push data to person" do
        @head.update_attributes!(:size => @size = "20lbs")
        assert_person
      end

      it "should nillify head fields in person when head is destroyed" do
        @person.update_attributes!(:head_size => "1000 balloons")
        @head.destroy
        @person.head_size.should be_nil
      end
    end
  end

  describe "one-to-many" do
    describe "from belongs_to side" do
      before do
        Head.send(:alize, :captor, *person_fields)
        @head.captor = @person
      end

      def assert_captor
        @head.captor_name.should == @name
      end

      it "should pull data from captor on create" do
        @head.save!
        assert_captor
      end

      it "should pull data from captor on save" do
        @head.save!
        @head.captor = Person.create(:name => @name = "Bill")
        @head.save!
        assert_captor
      end

      it "should push data to person" do
        @person.update_attributes!(:name => @name = "Bill")
        assert_captor
      end

      it "should nillify captor fields when person is destroyed" do
        @head.update_attributes!(:captor_name => "Old Gregg")
        @person.destroy
        @head.captor_name.should be_nil
      end
    end

    describe "from has_many side" do
      before do
        Head.send(:alize, :sees, *person_fields)
        @head.sees = [@person]
      end

      def assert_sees
        @head.sees_fields.should == [{
          "_id" => @person.id,
          "location" => "Paris",
          "name" => @name }]
      end

      it "should pull data from sees on create" do
        @head.save!
        assert_sees
      end

      it "should pull data from a sees on save" do
        @head.save!
        @head.sees = [@person = Person.create(:name => @name = "Bill")]
        @head.save!
        assert_sees
      end

      it "should push data to seen_by" do
        @person.update_attributes!(:name => @name = "Bill")
        assert_sees
      end

      it "should remove sees_fields entries in head when person is destroyed" do
        @head.save!
        assert_sees
        @person.destroy
        @head.sees_fields.should == []
        @head.reload.sees_fields.should == []
      end
    end
  end

  describe "many-to-many" do
    describe "has_and_belongs_to_many" do
      before do
        Head.send(:alize, :wanted_by, *person_fields)
      end

      def assert_wanted_by
        @head.wanted_by_fields.should == [{
          "_id" => @person.id,
          "location" => "Paris",
          "name" => @name }]
      end

      it "should pull data from wanted_by on create" do
        @head.wanted_by = [@person]
        @head.save!
        assert_wanted_by
      end

      it "should pull data from wanted_by on save" do
        @head.save!
        @person = Person.create(:name => @name = "Bill")
        @head.wanted_by = [@person]
        @head.save!
        assert_wanted_by
      end

      it "should push data to wants" do
        @person.wants = [@head]
        @person.update_attributes!(:name => @name = "Bill")
        assert_wanted_by
      end

      it "should remove wanted_by_fields entries in head when person is destroyed" do
        @head.wanted_by = [@person]
        @head.save!
        assert_wanted_by
        @person.destroy
        @head.reload
        @head.wanted_by_fields.should == []
        @head.reload.wanted_by_fields.should == []
      end
    end
  end

  describe "without specifying fields" do
    before do
      Head.send(:alize, :person)
      @head.person = @person
    end

    it "should denormalize all non-internal fields" do
      @head.save!
      @head.person_name.should == @name
      @head.person_created_at.to_i.should == @now.to_i
    end
  end

  describe "overriding denormalize methods for custom behavior on the from side" do
    before do
      class Person
        def denormalize_update_name_first
          self.name = "Overrider"
        end
      end

      class Head
        def denormalize_from_person
          self.person.denormalize_update_name_first
          _denormalize_from_person
        end
      end

      Head.send(:alize, :person, *person_fields)
      @head.person = @person
    end

    it "should be possible to define a method before alize and call the alize version within it" do
      @head.save!
      @head.person_name.should == "Overrider"
    end
  end

  describe "overriding denormalize methods for custom behavior on the to side" do
    before do
      class Person
        def denormalize_to_head
          self.name = "Overrider"
          _denormalize_to_head
        end
      end

      Head.send(:alize, :person, *person_fields)
      @head.person = @person
      @head.save!
    end

    it "should be possible to define a method before alize and call the alize version within it" do
      @person.update_attributes!(:name => @name = "Bill")
      @head.person_name.should == "Overrider"
    end
  end

  describe "forcing denormalization" do
    before do
      Head.send(:alize, :person, *person_fields)
      @head.person = @person
      @head.save!
    end

    it "should allow using the force flag to force denormalization" do
      class Head
        def denormalize_from_person
          _denormalize_from_person(true)
        end
      end

      @head.person_name = "Misty"
      @head.save!
      @head.person_name.should == @name
    end

    it "should allow using the force_denormalization attribute to force denormalization" do
      @head.person_name = "Misty"
      @head.force_denormalization = true
      @head.save!
      @head.person_name.should == @name
    end
  end
end
