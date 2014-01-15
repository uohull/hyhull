class Property < ActiveRecord::Base
  
  attr_accessible :name, :value, :property_type_id
  belongs_to :property_type 

  validates :name, presence: true
  validates :value, presence: true
  validates :property_type, presence: true  

  validates :name, uniqueness: { scope: :property_type_id }
  validates :value, uniqueness: { scope: :property_type_id }

  # Return a list of Property instances based upon the PropertyType Name
  def self.select_by_property_type_name(property_type_name)
    unless property_type_name.blank?
      property_type = PropertyType.where(name: property_type_name)

      unless property_type.empty?      
        Property.where(property_type_id: property_type.first.id)
      end     

    end
  end

end