# This ActiveRecord::Base class is used to store the Properties for Hyhull
# Property includes the attributes: name, value, property_type
# A property has one PropertyType
class Property < ActiveRecord::Base
  
  attr_accessible :name, :value, :property_type
  belongs_to :property_type 

  validates :name, presence: true
  validates :value, presence: true
  validates :property_type, presence: true  

  validates :name, uniqueness: { scope: :property_type_id }
  validates :value, uniqueness: { scope: :property_type_id }

  # Return a list of Property instances based upon the PropertyType Name
  def self.select_by_property_type_name(property_type_name, sort_by_property_name=true)
    unless property_type_name.blank?
      property_type = PropertyType.where(name: property_type_name)

      unless property_type.empty?
        if sort_by_property_name      
          Property.where(property_type_id: property_type.first.id).order(:name)
        else
          Property.where(property_type_id: property_type.first.id)
        end
      end     

    end
  end

end