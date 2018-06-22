require 'spec_helper'

describe Mongoid::Alize::ToCallback do

  before do
    @now = Time.parse('2013-01-05T12:00:22-700')

    Head.class_eval do
      field :sees_fields, :type => Array, :default => []
    end
    Person.class_eval do
      fields = [:name, :location, :created_at]
      fields += [:my_date, :my_datetime] if Mongoid::Compatibility::Version.mongoid4_or_newer?
      alize_to :seen_by, fields: fields
    end

    @head = Head.create(:sees => [@person = Person.create(sees_fields_without_id)])
    @person.seen_by = @head
  end

  def sees_fields_without_id
    fields = { "name"=> "Bob",
               "location" => "Paris",
               "created_at" => @now }

    fields.merge!( "my_date" => @now.to_date,
                   "my_datetime" => @now.to_datetime ) if Mongoid::Compatibility::Version.mongoid4_or_newer?

    fields
  end

  def sees_fields_with_id
    sees_fields_without_id.merge!( "_id" => @person.id )
  end

  def sees_fields_mongoized
    fields = sees_fields_with_id.merge!( "created_at"  => @now.utc )

    fields.merge!( "my_date"     => @now.utc.to_date,
                   "my_datetime" => @now.utc ) if Mongoid::Compatibility::Version.mongoid4_or_newer?

    fields
  end

  it "should push the mongoized values to the relation" do
    @head.sees_fields.should == [sees_fields_mongoized]
  end
end
