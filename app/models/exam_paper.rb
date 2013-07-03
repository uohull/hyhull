# app/models/exam_paper.rb
# Fedora object for the uketd ETD content type
class ExamPaper < ActiveFedora::Base
  include Hydra::ModelMethods
  include Hyhull::ModelMethods
  include Hyhull::ContentMetadataBehaviour
  include Hyhull::ResourceWorkflowBehaviour
  include Hyhull::Validators 

  # Extra validations for the resource_state state changes
  ExamPaper.state_machine :resource_state do   
    state :hidden, :deleted do
      validates :resource_status, presence: true
    end

    state :qa, :published do
      validates :title, presence: true
    end

  end

  before_save :apply_additional_metadata 

  has_metadata name: "descMetadata", label: "MODS metadata", type: Datastream::ModsExamPaper
  has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata

  #Delegate these attributes to the respective datastream
  #Unique fields
  delegate_to :descMetadata, [:department_name, :title, :date_issued, :rights, :language_text, :language_code, :publisher , :type_of_resource, 
  	                         :genre, :mime_type, :digital_origin, :identifier, :primary_display_url, :raw_object_url, :extent, :record_creation_date, 
                             :record_change_date, :resource_status, :exam_level, :additional_notes ], unique: true
  # Non-unique fields
  delegate_to :descMetadata, [:module_name, :module_code, :module_display]

  delegate_to :descMetadata, [:subject_topic]

  # Standard validations for the object fields
  #validates :title, presence: true
  validates :department_name, presence: true
  validates :module_name, array: { :length => { :minimum => 5 } }
  validates :module_code, array: { :length => { :minimum => 5 } } 
 # validates :module_display, array: { :length => { :minimum => 5 } }
  validates :date_issued, format: { with: /^(\d{4}-\d{2}-\d{2}|\d{4}-\d{2}|\d{4})/ }
  validates :subject_topic, array: { :length => { :minimum => 2 } }
  validates :publisher, presence: true

  def apply_additional_metadata 
    # May only need to set the title automaticallyin proto...   
    self.title = get_exam_title
    self.module_display = get_module_display

    if date_issued.empty? 
      copyright_year = ""
    else
      copyright_year = Date.parse(to_long_date(date_issued)).strftime("%Y")
    end

    self.rights = Datastream::ModsEtd.all_rights_reserved_statement(publisher, copyright_year)
  end

  def get_exam_title
    "#{get_module_display.join(', ')} (#{human_readable_date(date_issued)})"
  end

  def get_module_display
    module_display_array = []
    module_code.each_with_index do |code, index|
      module_display_array << "#{code} #{module_name[index]}"
    end
    return module_display_array 
  end

  def human_readable_date(date)
    Date.parse(to_long_date(date)).strftime("%B") + " " + Date.parse(to_long_date(date)).strftime("%Y")
  end

  # Overridden so that we can store a cmodel and "complex Object"
  def assert_content_model
    add_relationship(:has_model, "info:fedora/hydra-cModel:compoundContent")
    add_relationship(:has_model, "info:fedora/hydra-cModel:commonMetadata")
    super
  end

  # to_solr overridden to add object_type facet field to document
  def to_solr(solr_doc = {})
    super(solr_doc)
    solr_doc.merge!("object_type_sim" => "Examination paper")
    solr_doc
  end

end

