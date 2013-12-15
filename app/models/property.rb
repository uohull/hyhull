class Property < ActiveRecord::Base
  
  attr_accessible :name, :value
  belongs_to :property_type 

  validates :name, presence: true
  validates :value, presence: true
  validates :property_type, presence: true  
end