class Person
  include Mongoid::Document
  include Mongoid::Alize

  field :name, type: String
  field :created_at, type: Time

  if SpecHelper.mongoid_3?
    field :my_date, type: Date
    field :my_datetime, type: DateTime
  end

  # the attached head
  has_one :head

  # the heads taken from others
  has_many :heads, :class_name => "Head", :inverse_of => :captor

  # the heads wanted from others
  has_and_belongs_to_many :wants, :class_name => "Head", :inverse_of => :wanted_by

  # the only head that is watching
  belongs_to :seen_by, :class_name => "Head", :inverse_of => :sees

  # a polymorphic one-to-one relation
  has_one :nearest_head, :class_name => "Head", :as => :nearest

  # a polymorphic one-to-many relation
  belongs_to :above, :polymorphic => true

  def location
    "Paris"
  end

  # example of one way to handling attribute selection
  # for polymorphic associations or generally using the proc fields option
  def alize_fields(inverse)
    if inverse.is_a?(Head)
      [:size]
    else
      [:id]
    end
  end
end

