# app/models/uketd_object.rb
# Fedora object for the uketd ETD content type
class UketdObject < ActiveFedora::Base
  include Hydra::ModelMethods
  include Hyhull::ModelMethods
  include Hyhull::ContentMetadataBehaviour
  include Hyhull::GenericParentBehaviour
  include Hyhull::ResourceWorkflowBehaviour

  has_metadata :name => "descMetadata", type: Datastream::ModsEtd
  has_metadata :name => "rightsMetadata", type: Hydra::Datastream::RightsMetadata
 
  #Delegate these attributes to the respective datastream
  #Unique fields
  delegate_to :descMetadata, [:title, :abstract, :date_issued, :date_valid, :rights, :ethos_identifier, :language_text, :language_code, :publisher , :qualification_level, :qualification_name, 
                             :dissertation_category, :type_of_resource, :genre, :mime_type, :digital_origin, :identifier, :primary_display_url, :raw_object_url, :extent, :record_creation_date, 
                             :record_change_date], unique: true
  # Non-unique fields
  # People
  delegate_to :descMetadata, [:person_name, :person_role_text]
  # Organisations
  delegate_to :descMetadata, [:organisation_name, :organisation_role_text]
  delegate_to :descMetadata, [:subject_topic, :grant_number]
 
  # Static Relator terms 
  delegate :person_role_terms, to: Datastream::ModsEtd
  delegate :organisation_role_terms, to: Datastream::ModsEtd
  delegate :qualification_name_terms, to: Datastream::ModsEtd
  delegate :qualification_level_terms, to: Datastream::ModsEtd
  delegate :dissertation_category_terms, to: Datastream::ModsEtd
 
  # Overide the attributes method to enable the calling of custom methods
  def attributes=(properties)
    super(properties)
    self.descMetadata.add_names(properties["person_name"], properties["person_role_text"], "person") unless properties["person_name"].nil? or properties["person_role_text"].nil?
    self.descMetadata.add_names(properties["organisation_name"], properties["organisation_role_text"], "organisation") unless properties["organisation_name"].nil? or properties["organisation_role_text"].nil? 
    self.descMetadata.add_subject_topic(properties["subject_topic"])
    self.descMetadata.add_grant_number(properties["grant_number"])
  end
 
  # assert_content_model overidden to add UketdObject custom models
  def assert_content_model
    add_relationship(:has_model, "info:fedora/hydra-cModel:commonMetadata")
    super
  end
 
  # to_solr overridden to add object_type facet field to document
  def to_solr(solr_doc = {})
    super(solr_doc)
    solr_doc.merge!("object_type_sim" => "Thesis or dissertation")
    solr_doc
  end
 
 end