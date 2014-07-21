# -*- encoding : utf-8 -*-
class SolrDocument
  include Blacklight::Solr::Document
  include Hyhull::Solr::DocumentExt

  SolrDocument.use_extension( Hyhull::OAI::Provider::BlacklightOaiProvider::SolrDocumentExtension )

  # self.unique_key = 'id'
  
  # The following shows how to setup this blacklight document to display marc documents
  extension_parameters[:marc_source_field] = :marc_display
  extension_parameters[:marc_format_type] = :marcxml
  use_extension( Blacklight::Solr::Document::Marc) do |document|
    document.key?( :marc_display  )
  end
  
  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Email )
  
  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Sms )

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Hyhull::Solr::Document::DublinCore)
  use_extension( Hyhull::Solr::Document::UketdDc) 

  field_semantics.merge!(    
                         :title => "title_tesim",
                         :creator => "creator_name_ssim",
                         :language => "language_text_ssm",
                         :description => "description_ssm",
                         :abstract => "abstract_ssm",
                         :subject => "subject_topic_ssm",
                         :date => "date_issued_ssm",
                         :issued => "date_issued_ssm",
                         :date_created => "system_create_dtsi",
                         :format => "format",                         
                         :type => "genre_ssm",
                         :language => "language_code_ssm",
                         :language_text => "language_text_ssm",
                         :identifier => "id",
                         :rights => "rights_ssm",
                         :publisher => "publisher_ssm",
                         :qualificationlevel => "qualification_level_ssm",
                         :qualificationname => "qualification_name_ssm",
                         :advisor => "supervisor_name_ssm",
                         :sponsor => "sponsor_name_ssm"
                         )

end