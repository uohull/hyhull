# app/models/dataset.rb
# Fedora object for the Dataset
class Dataset < GenericContent
  # Dataset is a slightly specialised 'GenericContent' Resource, so only specifying overides

  before_save :apply_additional_metadata 

  # Use the specialised ModsDataset
  has_metadata name: "descMetadata", label: "MODS metadata", type: Datastream::ModsDataset

  # Static Relator terms 
  delegate :person_role_terms, to: Datastream::ModsDataset
  delegate :organisation_role_terms, to: Datastream::ModsDataset
  delegate :coordinates_types, to: Datastream::ModsDataset

  validates :type_of_resource, presence: true 

  # Overridden so that we can store a cmodel and "complex Object"
  def assert_content_model
    add_relationship(:has_model, "info:fedora/hull-cModel:dataset")  
    add_relationship(:has_model, "info:fedora/hydra-cModel:compoundContent")
    add_relationship(:has_model, "info:fedora/hydra-cModel:commonMetadata")    
  end

  def apply_additional_metadata
  end

end

