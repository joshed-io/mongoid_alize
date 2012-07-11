require 'spec_helper'

describe Mongoid::Alize::InstanceHelpers do

  def from_klass
    Mongoid::Alize::Callbacks::From::One
  end

  def to_klass
    Mongoid::Alize::Callbacks::To::OneFromOne
  end

  before do
    @head =
      Head.new(person:
               @person = Person.create(:name => @name = "Bob"))
  end

  describe "#denormalize_from_all" do
    it "should run the alize callbacks" do
      Head.alize_callbacks <<
          callback = from_klass.new(Head, :person, [:name])
      mock(@head).denormalize_from_person
      @head.denormalize_from_all
    end
  end

  describe "#denormalize_to_all" do
    it "should run the alize callbacks" do
      Person.alize_inverse_callbacks <<
          callback = to_klass.new(Person, :head, [:size])
      mock(@person).denormalize_to_head
      @person.denormalize_to_all
    end
  end
end
