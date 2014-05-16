# app/models/generic_content.rb
# Fedora object for the Generic content type
class GenericContent < ActiveFedora::Base
  include Hydra::ModelMethods
  include Hyhull::ModelMethods
  include Hyhull::GenericContentBehaviour
  include Hyhull::ContentMetadataBehaviour
  include Hyhull::ResourceWorkflowBehaviour
  include Hyhull::Validators
  include Hyhull::FullTextIndexableBehaviour 

  # Extra validations for the resource_state state changes
  GenericContent.state_machine :resource_state do   
    state :hidden, :deleted do
      validates :resource_status, presence: true
    end

    state :qa, :published do
      validates :title, presence: true
    end

  end

  before_save :apply_additional_metadata 

  has_metadata name: "descMetadata", label: "MODS metadata", type: Datastream::ModsGenericContent
  has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata

  # has_attributes to the terms 'at' to save clashes with the related_web_url
  has_attributes :primary_display_url, datastream: :descMetadata, at: [:mods, :location_element, :primary_display], multiple: false
  has_attributes :raw_object_url, datastream: :descMetadata, at: [:mods, :location_element, :raw_object], multiple: false

  # Attributes to respective datastream
  # Unique fields
  has_attributes :title, :version, :date_valid, :date_issued, :location_coordinates, :location_label, :location_coordinates_type, :language_text, :language_code, 
                   :publisher, :type_of_resource, :description, :genre, :mime_type, :digital_origin, :identifier, :doi, :record_creation_date, 
                     :record_change_date, :resource_status, :additional_notes, 
                     datastream: :descMetadata, multiple: false

  # Non-unique fields
  has_attributes :related_web_url, :see_also, :extent, :rights, :subject_temporal, :subject_geographic, :citation, :software,
                 datastream: :descMetadata, multiple: true
  # Subjects
  has_attributes :subject_topic, datastream: :descMetadata, multiple: true
  # People
  has_attributes :person_name, :person_role_text, datastream: :descMetadata, multiple: true
  # Organisations
  has_attributes :organisation_name, :organisation_role_text, datastream: :descMetadata, multiple: true

  # Static Relator terms 
  delegate :person_role_terms, to: Datastream::ModsGenericContent, multiple: false
  delegate :organisation_role_terms, to: Datastream::ModsGenericContent, multiple: false
  delegate :coordinates_types, to: Datastream::ModsGenericContent, multiple: false

  # Standard validations for the object fields
  validates :title, presence: true
  validates :genre, presence: true
  validates :subject_topic, array: { :length => { :minimum => 2 } }
  validates :language_code, presence: true
  validates :language_text, presence: true 

  # Overridden so that we can store a cmodel and "complex Object"
  def assert_content_model
    g = Genre.find(self.genre)
    add_relationship(:has_model, "info:fedora/#{g.c_model}")  
    add_relationship(:has_model, "info:fedora/hydra-cModel:compoundContent")
    add_relationship(:has_model, "info:fedora/hydra-cModel:commonMetadata")    
  end

  def apply_additional_metadata
    # Apply the following additional metadata
    # Only autoset type_of_resource in proto...
    if self.resource_proto?    
      self.type_of_resource = Genre.find(self.genre).type if Genre.find(self.genre).type.class == String
    end
  end

  # Overide the attributes method to enable the calling of custom methods
  def attributes=(properties)
    super(properties)
    self.descMetadata.add_names(properties["person_name"], properties["person_role_text"], "person") unless properties["person_name"].nil? or properties["person_role_text"].nil?
    self.descMetadata.add_names(properties["organisation_name"], properties["organisation_role_text"], "organisation") unless properties["organisation_name"].nil? or properties["organisation_role_text"].nil? 
  end

  # to_solr overridden to add object_type facet field to document
  def to_solr(solr_doc = {})
    super(solr_doc)
    solr_doc.merge!("object_type_sim" => self.genre)
    solr_doc
  end

end

