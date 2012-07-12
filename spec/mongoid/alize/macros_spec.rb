require 'spec_helper'

describe Mongoid::Alize::Macros do
  def person_default_fields
    ["name", "created_at", "want_ids", "seen_by_id"]
  end

  def head_default_fields
    ["size", "weight", "person_id", "captor_id", "wanted_by_ids"]
  end

  describe "#alize_to and #alize_from" do
    describe "with a belongs_to" do
      it_should_set_callbacks(Head, Person,
                             :person, :head,
                             fns::One, tns)
    end

    describe "with a has_one" do
      it_should_set_callbacks(Person, Head,
                             :head, :person,
                             fns::One, tns)
    end

    describe "with a has_many from the belongs_to side" do
      it_should_set_callbacks(Head, Person,
                             :captor, :heads,
                             fns::One, tns)
    end

    describe "with a has_many from the has_many side" do
      it_should_set_callbacks(Head, Person,
                             :sees, :seen_by,
                             fns::Many, tns)
    end

    describe "with a has_and_belongs_to_many" do
      it_should_set_callbacks(Head, Person,
                             :wanted_by, :wants,
                             fns::Many, tns)
    end

    describe "#alize" do
      it "should call alize_from" do
        mock(Head).alize_from(:person, :name)
        Head.alize(:person, :name)
      end

      it "should call alize_to if relation is not polymorphic" do
        mock(Person).alize_to(:head, :name)
        Head.alize(:person, :name)
      end

      describe "with a polymorphic association" do
        it "should attach an inverse callback to the parent side" do
          Person.relations["nearest_head"].should be_polymorphic
          Person.relations["nearest_head"].should_not be_stores_foreign_key
          Person.relations["nearest_head"].klass.should == Head
          mock.proxy(Mongoid::Alize::ToCallback).new(Head, :nearest, head_default_fields)
          Person.alize(:nearest_head)
        end

        it "should not attach a callback on the child side" do
          Head.relations["nearest"].should be_polymorphic
          Head.relations["nearest"].should be_stores_foreign_key
          dont_allow(Mongoid::Alize::ToCallback).new
          Head.alize(:nearest)
        end
      end

      describe "when no inverse is present" do
        it "should add only a from callback" do
          Head.relations["admirer"].inverse.should be_nil
          dont_allow(Mongoid::Alize::ToCallback).new
          Head.alize(:admirer)
        end
      end
    end

    describe "#alize_to" do
      describe "with fields supplied" do
        it "should use them" do
          mock.proxy(Mongoid::Alize::ToCallback).new(Person, :head, [:foo, :bar])
          Person.alize_to(:head, :foo, :bar)
        end
      end

      describe "with no fields supplied" do
        it "should use the default alize fields" do
          mock.proxy(Mongoid::Alize::ToCallback).new(Person, :head, person_default_fields)
          Person.alize_to(:head)
        end
      end

      describe "with a block supplied" do
        it "should use the block supplied as fields in the options hash" do
          blk = lambda {}
          mock.proxy(Mongoid::Alize::ToCallback).new(Person, :head, blk)
          Person.alize_to(:head, :foo, :fields => blk)
        end
      end
    end

    describe "#alize_from" do
      describe "with fields supplied" do
        it "should use them" do
          mock.proxy(Mongoid::Alize::Callbacks::From::One).new(
            Head, :person, [:foo, :bar])
          Head.alize_from(:person, :foo, :bar)
        end
      end

      describe "with no fields supplied" do
        it "should use the default alize fields" do
          mock.proxy(Mongoid::Alize::Callbacks::From::One).new(
            Head, :person, person_default_fields)
          Head.alize_from(:person)
        end
      end

      describe "with a block supplied" do
        it "should use the block supplied as fields in the options hash" do
          blk = lambda {}
          mock.proxy(Mongoid::Alize::Callbacks::From::One).new(
            Head, :person, blk)
          Head.alize_from(:person, :foo, :fields => blk)
        end
      end
    end

    describe "default_alize_fields" do
      it "should return an array of all non-internal field names (e.g. not _type or _id)" do
        Head.default_alize_fields.should == head_default_fields
        Person.default_alize_fields.should == person_default_fields
      end
    end
  end
end
