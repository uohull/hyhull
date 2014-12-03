# app/models/book.rb
# Fedora object for the Book content type
class Book < ActiveFedora::Base
  include Hydra::ModelMethods
  include Hyhull::ModelMethods
  include Hyhull::GenericContentBehaviour
  include Hyhull::ContentMetadataBehaviour
  include Hyhull::ResourceWorkflowBehaviour
  include Hyhull::Validators
  include Hyhull::FullTextIndexableBehaviour

  # Extra validations for the resource_state state changes
  Book.state_machine :resource_state do   
    state :hidden, :deleted do
      validates :resource_status, presence: true
    end

    state :qa, :published do
      validates :title, presence: true
    end
  end


  has_metadata name: "descMetadata", label: "MODS metadata", type: Datastream::ModsBook
  has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata

  has_attributes :title, :subtitle, :date_valid, :date_issued, :language_text, :language_code, 
                   :publisher, :type_of_resource, :description, :genre, :mime_type, :digital_origin, :identifier, :doi, :record_creation_date, :peer_reviewed,
                     :record_change_date, :resource_status, :additional_notes,  :converis_publication_id, 
                     :related_item_print_issn, :related_item_electronic_issn, :related_item_isbn,  :related_item_doi, 
                     :related_item_restriction, :related_item_publications_note, :unit_of_assessment, :primary_display_url, :raw_object_url,
                     datastream: :descMetadata, multiple: false

  # Addtional fields that the Book CModel makes use of...
   has_attributes  :related_item_date, :related_item_publisher, :related_item_issuance, :related_item_place, :series_title, :related_item_physical_extent, :related_item_form, datastream: :descMetadata, 
       multiple: false

  # Non-unique fields
  has_attributes :related_web_url, :see_also, :rights, :citation, :extent,
                 datastream: :descMetadata, multiple: true

  # Subjects
  has_attributes :subject_topic, datastream: :descMetadata, multiple: true
  # People
  has_attributes :person_name, :person_role_text, datastream: :descMetadata, multiple: true
  # Organisations
  has_attributes :organisation_name, :organisation_role_text, datastream: :descMetadata, multiple: true

  # Static Relator terms 
  delegate :person_role_terms, to: Datastream::ModsBook, multiple: false
  delegate :organisation_role_terms, to: Datastream::ModsBook, multiple: false
  delegate :issuance_terms, to: Datastream::ModsBook, multiple: false
  delegate :marc_form_terms, to: Datastream::ModsBook, multiple: false

  # Standard validations for the object fields
  validates :title, presence: true
  validates :genre, presence: true
  validates :subject_topic, array: { :length => { :minimum => 2 } }

  # Overridden so that we can store a cmodel and "complex Object"
  def assert_content_model
    add_relationship(:has_model, "info:fedora/hull-cModel:book")  
    add_relationship(:has_model, "info:fedora/hydra-cModel:compoundContent")
    add_relationship(:has_model, "info:fedora/hydra-cModel:commonMetadata")    
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
    solr_doc.merge!("object_type_sim" => "Book")
    solr_doc
  end  

end