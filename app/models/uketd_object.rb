# app/models/uketd_object.rb
# Fedora object for the uketd ETD content type
class UketdObject < ActiveFedora::Base
  include Hydra::ModelMethods
  include Hyhull::ModelMethods
  include Hyhull::ContentMetadataBehaviour 

  has_metadata :name => "descMetadata", type: Datastream::ModsEtd
  has_metadata :name => "rightsMetadata", type: Hydra::Datastream::RightsMetadata

  #Delegate these attributes to the respective datastream
  #Unique fields
  delegate :title, :to=>"descMetadata", :unique=>"true"
  delegate :abstract, :to=>"descMetadata", :unique=>"true"
  delegate :date_issued, :to=>"descMetadata", :unique=>"true"
  delegate :date_valid, :to=>"descMetadata", :unique=>"true"
  delegate :rights, :to=>"descMetadata", :unique=>"true"
  delegate :ethos_identifier, :to=>"descMetadata", :unique=>"true"
  delegate :language_text, :to=>"descMetadata", :unique=>"true"
  delegate :language_code, :to=>"descMetadata", :unique=>"true"
  delegate :publisher, :to=>"descMetadata", :unique=>"true"
  delegate :qualification_level, :to=>"descMetadata", :unique=>"true"
  delegate :qualification_name, :to=>"descMetadata", :unique=>"true"
  delegate :dissertation_category, :to=>"descMetadata", :unique=>"true"
  delegate :type_of_resource, :to=>"descMetadata", :unique=>"true"
  delegate :genre, :to=>"descMetadata", :unique=>"true"
  delegate :mime_type, :to=>"descMetadata", :unique=>"true"
  delegate :digital_origin, :to=>"descMetadata", :unique=>"true"
  delegate :identifier, :to=>"descMetadata", :unique=>"true"
  delegate :primary_display_url, :to=>"descMetadata", :unique=>"true"
  delegate :raw_object_url, :to=>"descMetadata", :unique=>"true"
  delegate :extent, :to=>"descMetadata", :unique=>"true"
  delegate :record_creation_date, :to=>"descMetadata", :unique=>"true"
  delegate :record_change_date, :to=>"descMetadata", :unique=>"true"

  # Non-unique fields
  # People
  delegate :person_name, :to=>"descMetadata"
  delegate :person_role_text, :to=>"descMetadata"

  # Organisations
  delegate :organisation_name, :to=>"descMetadata"
  delegate :organisation_role_text, :to=>"descMetadata"

  delegate :subject_topic, :to=>"descMetadata"
  delegate :grant_number, :to=>"descMetadata"

  # Relator terms
  delegate :person_role_terms, to: Datastream::ModsEtd
  delegate :organisation_role_terms, to: Datastream::ModsEtd
  delegate :qualification_name_terms, to: Datastream::ModsEtd
  delegate :qualification_level_terms, to: Datastream::ModsEtd
  delegate :dissertation_category_terms, to: Datastream::ModsEtd

  # Overide the update_attributes method to enable the calling of custom methods
  def update_attributes(params = {})
    super(params)
    self.descMetadata.add_names(params["person_name"], params["person_role_text"], "person") unless params["person_name"].nil? or params["person_role_text"].nil?
    self.descMetadata.add_names(params["organisation_name"], params["organisation_role_text"], "organisation") unless params["organisation_name"].nil? or params["organisation_role_text"].nil? 
    self.descMetadata.add_subject_topic(params["subject_topic"])
    self.descMetadata.add_grant_number(params["grant_number"])
  end

  # assert_content_model overidden to add UketdObject custom models
  def assert_content_model
    add_relationship(:has_model, "info:fedora/hydra-cModel:commonMetadata")
    add_relationship(:has_model, "info:fedora/hydra-cModel:genericParent")
    super
  end

  # to_solr overridden to add object_type facet field to document
  def to_solr(solr_doc = {})
    super(solr_doc)
    solr_doc.merge!("object_type_sim" => "Thesis or dissertation")
    solr_doc
  end

end

