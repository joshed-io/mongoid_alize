class Head
  include Mongoid::Document
  include Mongoid::Alize

  field :size, type: Integer
  field :weight

  # to whom it's attached
  belongs_to :person

  # in who's possession it is
  belongs_to :captor, :class_name => "Person", :inverse_of => :heads

  # who'd otherwise like to possess it
  has_and_belongs_to_many :wanted_by, :class_name => "Person", :inverse_of => :wants

  # who it sees
  has_many :sees, :class_name => "Person", :inverse_of => :seen_by

  # a relation with no inverse
  has_many :admirer, :class_name => "Person", :inverse_of => nil

  def density
    "low"
  end
end
