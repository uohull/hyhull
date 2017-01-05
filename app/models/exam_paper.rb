# app/models/exam_paper.rb
# Fedora object for the Exam paper content type
class ExamPaper < ActiveFedora::Base
  include Hydra::ModelMethods
  include Hyhull::ModelMethods
  include Hyhull::GenericContentBehaviour
  include Hyhull::ContentMetadataBehaviour
  include Hyhull::ResourceWorkflowBehaviour
  include Hyhull::Validators
  include Hyhull::FullTextIndexableBehaviour 

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

  # Attributes to respective datastream - Multiple false
  has_attributes :department_name, :title, :date_issued, :rights, :language_text, :language_code, :publisher , :type_of_resource, 
                   :genre, :mime_type, :digital_origin, :identifier, :primary_display_url, :raw_object_url, :extent, :record_creation_date, 
                     :record_change_date, :resource_status, :exam_level, :additional_notes, datastream: :descMetadata, multiple: false  
  
  # Multple true
  # Modules
  has_attributes :module_name, :module_code, :module_display, datastream: :descMetadata, multiple: true

  # Subject
  has_attributes :subject_topic, datastream: :descMetadata, multiple: true

  # Standard validations for the object fields
  #validates :title, presence: true
  validates :department_name, presence: true
  validates :module_name, array: { :length => { :minimum => 3 } }
  validates :module_code, array: { :length => { :minimum => 5 } } 
  # validates :module_display, array: { :length => { :minimum => 5 } }
  #validates :date_issued, format: { with: /^(\d{4}-\d{2}-\d{2}|\d{4}-\d{2}|\d{4})/ }
  validates :date_issued, format: { with: /^(\d{4}-\w{1}\d{1})|(\d{4})/ }
  validates :subject_topic, array: { :length => { :minimum => 2 } }
  validates :publisher, presence: true

  def apply_additional_metadata 
    # Only autoset title in proto...
    if self.resource_proto?    
      self.title = get_exam_title
    end

    self.module_display = get_module_display

    if date_issued.empty? 
      copyright_year = ""
    else
      #copyright_year = Date.parse(to_long_date(date_issued)).strftime("%Y")
      copyright_year = date_issued[0..3]
    end

    self.rights = Datastream::ModsExamPaper.all_rights_reserved_statement(publisher, copyright_year)
  end

  def get_exam_title
    session_issued = ""

    unless date_issued[5..6].nil?
      session_issued = date_issued[5..6].upcase
    end

    case session_issued
      when "S1"
        return "#{get_module_display.join(' & ')} Semester 1 #{date_issued[0..3]}"
      when "S2"
        return "#{get_module_display.join(' & ')} Semester 2 #{date_issued[0..3]}"
      when "S3"
        return "#{get_module_display.join(' & ')} Semester 3 #{date_issued[0..3]}"
      else
        begin
          "#{get_module_display.join(' & ')} (#{human_readable_date(date_issued)})"
        rescue
          return get_module_display
        end
    end

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

  # Overide the attributes method to enable the calling of custom methods
  def attributes=(properties)
    super(properties)
    self.descMetadata.add_modules(properties["module_code"], properties["module_name"], get_module_display()) unless properties["module_code"].nil? or properties["module_name"].nil? 
  end

  # to_solr overridden to add object_type facet field to document
  def to_solr(solr_doc = {})
    super(solr_doc)
    solr_doc.merge!("object_type_sim" => "Examination paper")
    solr_doc
  end

end

