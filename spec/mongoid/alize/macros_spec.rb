require 'spec_helper'

describe Mongoid::Alize::Macros do
  describe "#alize" do
    describe "with a belongs_to" do
      it_should_set_callbacks(Head, Person,
                             :person, :head,
                             fns::One, tns::OneFromOne)
    end

    describe "with a has_one" do
      it_should_set_callbacks(Person, Head,
                             :head, :person,
                             fns::One, tns::OneFromOne)
    end

    describe "with a has_many from the belongs_to side" do
      it_should_set_callbacks(Head, Person,
                             :captor, :heads,
                             fns::One, tns::OneFromMany)
    end

    describe "with a has_many from the has_many side" do
      it_should_set_callbacks(Head, Person,
                             :sees, :seen_by,
                             fns::Many, tns::ManyFromOne)
    end

    describe "with a has_and_belongs_to_many" do
      it_should_set_callbacks(Head, Person,
                             :wanted_by, :wants,
                             fns::Many, tns::ManyFromMany)
    end

    describe "when no inverse is present" do
      it "should add only a from and not a to callback" do
        dont_allow(Mongoid::Alize::Callbacks::To::OneFromOne).new
        Head.alize(:admirer)
      end
    end

    describe "with a polymorphic association" do
      it "should not attach a callback to the inverse" do
        Head.relations["nearest"].should be_polymorphic
        dont_allow(Mongoid::Alize::Callbacks::To::OneFromOne).new
        Head.alize(:nearest)
      end

      it "should not attach a callback to the inverse on the as side either" do
        Head.relations["below"].should be_polymorphic
        dont_allow(Mongoid::Alize::Callbacks::To::OneFromOne).new
        Head.alize(:below)
      end
    end

    describe "fields" do
      describe "with fields supplied" do
        it "should use them" do
          dont_allow(Head).default_alize_fields
          Head.alize(:person, :name)
        end
      end

      describe "with no fields supplied" do
        it "should use the default alize fields" do
          mock(Head).default_alize_fields(anything) { [:name] }
          Head.alize(:person)
        end
      end

      describe "with a block supplied" do
        it "should use the block supplied as fields in the options hash" do
          blk = lambda {}
          mock.proxy(Mongoid::Alize::Callbacks::From::One).new(
            Head, :person, blk)
          Head.alize(:person, :fields => blk)
        end
      end
    end

    describe "default_alize_fields" do
      it "should return an array of all non-internal field names (e.g. not _type or _id)" do
        Head.default_alize_fields(Head.relations["person"]).should ==
          ["name", "created_at", "want_ids", "seen_by_id"]
      end

      it "should be empty for a polymorphic association" do
        Head.default_alize_fields(Head.relations["nearest"]).should ==
          []
      end
    end
  end
end
