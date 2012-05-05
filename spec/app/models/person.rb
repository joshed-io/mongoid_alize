class Person
  include Mongoid::Document
  include Mongoid::Alize

  field :name, type: String
  field :created_at, type: Time

  # the attached head
  has_one :head

  # the heads taken from others
  has_many :heads, :class_name => "Head", :inverse_of => :captor

  # the heads wanted from others
  has_and_belongs_to_many :wants, :class_name => "Head", :inverse_of => :wanted_by

  # the only head that is watching
  belongs_to :seen_by, :class_name => "Head", :inverse_of => :sees

end

