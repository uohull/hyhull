# app/models/journal_article.rb
# Fedora object for the Journal Article content type
class JournalArticle < ActiveFedora::Base
  include Hydra::ModelMethods
  include Hyhull::ModelMethods
  include Hyhull::GenericContentBehaviour
  include Hyhull::ContentMetadataBehaviour
  include Hyhull::ResourceWorkflowBehaviour
  include Hyhull::Validators
  include Hyhull::FullTextIndexableBehaviour 

  # Extra validations for the resource_state state changes
  JournalArticle.state_machine :resource_state do   
    state :hidden, :deleted do
      validates :resource_status, presence: true
    end
    state :qa, :published do
      validates :title, presence: true
    end

  end

  has_metadata name: "descMetadata", label: "MODS metadata", type: Datastream::ModsJournalArticle
  has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata

  # Attributes to respective datastream
  # Multiple false
  has_attributes :title, datastream: :descMetadata, at: [:mods, :title_info, :main_title], multiple: false
  has_attributes :title_alternative, datastream: :descMetadata, at: [:mods, :title_info_alternative, :main_title_alternative], multiple: false
  has_attributes :publisher, datastream: :descMetadata, at: [:mods, :origin_info, :publisher], multiple: false

  has_attributes :abstract, :rights, :language_text, :language_code, :date_issued,
                 :peer_reviewed, :journal_title, :journal_date_other, :journal_publisher, :journal_publication_date, :journal_print_issn,
                 :journal_electronic_issn, :journal_article_doi, :journal_volume, :journal_issue,  :journal_start_page,
                 :journal_end_page, :journal_article_restriction, :journal_publications_note, :type_of_resource, :genre, :mime_type, :digital_origin, 
                 :identifier, :primary_display_url, :raw_object_url, :extent, :record_creation_date, :record_change_date, :resource_status, :converis_publication_id, :unit_of_assessment,
                 datastream: :descMetadata, multiple: false

  # Non-unique fields
  # Subjects
  has_attributes :subject_topic, datastream: :descMetadata, multiple: true
  # People
  has_attributes :person_name, :person_role_text, :person_role_code, :person_affiliation, datastream: :descMetadata, multiple: true
  # has_attributes :person_affiliation, datastream: :descMetadata, multiple: true

  # Journal URLS
  has_attributes :journal_url, :journal_url_access, :journal_url_display_label, datastream: :descMetadata, multiple: true

  # REF exceptions
  has_attributes :ref_exception, :ref_exception_technical, 
                 :ref_exception_deposit, :ref_exception_access, 
                 :ref_exception_other, datastream: :descMetadata, 
                 multiple: false

  # RIOXX fields
  has_attributes :apc, :project_id, :project_funder_id, :project_funder_name,
                 :free_to_read_start_date, :free_to_read_end_date,
                 :licence_ref_start_date, :licence_url,
                 datastream: :descMetadata, multiple: false

  # Static Relator terms 
  delegate :person_role_terms, to: Datastream::ModsJournalArticle, multiple: false
  delegate :url_access_terms, to: Datastream::ModsJournalArticle, multiple: false
  delegate :person_affiliation_terms, to: Datastream::ModsJournalArticle, multiple: false

  # Standard validations for the object fields
  validates :title, presence: true
  validates :person_name, array: { :length => { :minimum => 3 } }
  validates :person_role_text, array: { :length => { :minimum => 3 } } 
  # validates :person_affiliation, array: { :length => { :minimum => 1 } }
  validates :subject_topic, array: { :length => { :minimum => 2 } }
  validates :publisher, presence: true
  validates :free_to_read_start_date, format: { with: /^$|(\d{4}-\d{2}-\d{2})/ }
  validates :free_to_read_end_date, format: { with: /^$|(\d{4}-\d{2}-\d{2})/ }
  validates :licence_ref_start_date, format: { with: /^$|(\d{4}-\d{2}-\d{2})/ }

  # Overridden so that we can store a cmodel and "complex Object"
  def assert_content_model
    add_relationship(:has_model, "info:fedora/hydra-cModel:compoundContent")
    add_relationship(:has_model, "info:fedora/hydra-cModel:commonMetadata")
    super
  end

  # Overide the attributes method to enable the calling of custom 
  # methods : names, roles, type, affiliation, journal url and ref exception
  def attributes=(properties)
    super(properties)

    # custom method: names, roles, type, affiliation
    self.descMetadata.add_names(
      properties["person_name"], 
      properties["person_role_text"], 
      "person", 
      properties["person_affiliation"]
    ) unless properties["person_name"].nil? or properties["person_role_text"].nil? or properties["person_affiliation"].nil?

    # custom method: journal url
    self.descMetadata.add_journal_urls(
      properties["journal_url"], 
      properties["journal_url_access"], 
      properties["journal_url_display_label"]
    ) unless properties["journal_url"].nil? or properties["journal_url_access"].nil? or properties["journal_url_display_label"].nil?

    # custom method: ref exception
    self.descMetadata.add_ref_exception (
      properties["ref_exception"]
    ) unless properties["ref_exception"].nil?
  end

  # to_solr overridden to add object_type facet field to document and to add title/publisher fields that are not handled in ModsJounalArticle
  def to_solr(solr_doc = {})
    super(solr_doc)
    solr_doc.merge!("object_type_sim" => "Journal article", "title_tesim" => self.title, "publisher_ssm" => self.publisher, "title_alternative_tesim" => self.title_alternative)
    solr_doc
  end

end
