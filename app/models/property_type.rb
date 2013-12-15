class PropertyType < ActiveRecord::Base
  
  has_many :properties 
  attr_accessible :name, :description
  
  validates :name, presence: true
  validates :description, presence: true
end
