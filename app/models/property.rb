class Property < ActiveRecord::Base
  
  attr_accessible :name, :value
  belongs_to :property_type 

  validates :name, presence: true
  validates :value, presence: true
  validates :property_type, presence: true  

  validates :name, uniqueness: { scope: :property_type_id }
  validates :value, uniqueness: { scope: [:name, :property_type_id] }

end