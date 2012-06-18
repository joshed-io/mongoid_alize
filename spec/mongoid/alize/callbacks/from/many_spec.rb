require 'spec_helper'

describe Mongoid::Alize::Callbacks::From::Many do
  def klass
    Mongoid::Alize::Callbacks::From::Many
  end

  def args
    [Head, :wanted_by, [:name, :created_at]]
  end

  def new_unit
    klass.new(*args)
  end

  describe "#define_fields" do
    it "should define an Array called {relation}_fields" do
      unit = new_unit
      unit.send(:define_fields)
      Head.fields["wanted_by_fields"].type.should == Array
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

      @unit = new_unit
      @unit.send(:define_fields)
      @unit.send(:define_callback)
    end

    it "should pull the fields from the relation" do
      @head.wanted_by_fields.should be_nil
      run_callback
      @head.wanted_by_fields.should == [{
        "_id" => @person.id,
        "name"=> "Bob",
        "created_at"=> @now.to_s(:utc)
      }]
    end
  end
end
