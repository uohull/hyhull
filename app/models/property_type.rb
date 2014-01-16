# This ActiveRecord::Base class is used to store the PropertyType for Hyhull
# PropertyType has a name and description
# Name is generally used in the Property helper for display dropdown selects
class PropertyType < ActiveRecord::Base
  
  has_many :properties 
  attr_accessible :name, :description
  
  validates :name, presence: true
  validates :description, presence: true
end
