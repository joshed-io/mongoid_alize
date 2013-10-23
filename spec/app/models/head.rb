class Head
  include Mongoid::Document
  include Mongoid::Alize

  if SpecHelper.mongoid_4?
    include Mongoid::Attributes::Dynamic
  end

  field :size, type: Integer
  field :weight

  # to whom it's attached
  belongs_to :person

  # in whose possession it is
  belongs_to :captor, :class_name => "Person", :inverse_of => :heads

  # who'd otherwise like to possess it
  has_and_belongs_to_many :wanted_by, :class_name => "Person", :inverse_of => :wants

  # who it sees
  has_many :sees, :class_name => "Person", :inverse_of => :seen_by

  # a relation with no inverse
  has_many :admirer, :class_name => "Person", :inverse_of => nil

  # a polymorphic one-to-one relation
  belongs_to :nearest, :polymorphic => true

  # a polymorphic one-to-many relation
  has_many :below_people, :class_name => "Person", :as => :above

  def density
    "low"
  end

  # example of one way to handling attribute selection
  # for polymorphic associations or generally using the proc fields option
  def alize_fields(inverse)
    if inverse.is_a?(Person)
      [:name, :location]
    else
      [:id]
    end
  end
end
