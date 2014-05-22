module SearchOptimisationMetaHelper
  # This Helper module can be used to add meta tags to Show pages.  This will improve searchability within Google etc.. 
  # Also adds highwire_press meta tags to help with Google Scholar indexing
  # Can be used with Show.html.erb
  # See rails.root/config/meta_tag_solr_mappings.rb for the meta tags -> solr field mappings 

  # Method returns an array of metatags
  def meta_tags(document)
     meta_tags = []
     begin 
       meta_tags.concat(dc_meta_tags(document))
     rescue
       logger.error("Failed to create dc_meta_tags")       
     end

     begin 
       meta_tags.concat(highwire_press_meta_tags(document))
     rescue
       logger.error("Failed to create highwire_press_meta_tags")       
     end  
     return meta_tags
  end

  def dc_meta_tags(document)
    dc_meta_tags = []
    dc_meta_tags << meta_tag("dc.Title", title(document, string_output: true))
  end

  # Highwire press tags are the recommended meta tags for Google Scholar compatability 
  def highwire_press_meta_tags(document)
    highwire_press_meta_tags = []    

    # citation_title 
    highwire_press_meta_tags << meta_tag("citation_title", title(document, string_output: true))
    # citation_author
    authors = author(document)
    authors.each { |name| highwire_press_meta_tags << meta_tag("citation_author", name) } unless authors.nil?    
    # citation_date
    highwire_press_meta_tags << meta_tag("citation_publication_date", meta_date(document))
    # citation_publisher
    highwire_press_meta_tags << meta_tag("citation_publisher", publisher(document, string_output: true))
    # citation_journal_title
    highwire_press_meta_tags << meta_tag("citation_journal_title", journal_title(document, string_output: true))
    # citation_volume
    highwire_press_meta_tags << meta_tag("citation_volume", journal_volume(document, string_output: true))
    # citation_issue
    highwire_press_meta_tags << meta_tag("citation_issue", journal_issue(document, string_output: true))
    # citation_firstpage
    highwire_press_meta_tags << meta_tag("citation_firstpage", journal_start_page(document, string_output: true))
    # citation_lastpage
    highwire_press_meta_tags << meta_tag("citation_lastpage", journal_end_page(document, string_output: true))
    # citation_doi
    highwire_press_meta_tags << meta_tag("citation_doi", doi(document, string_output: true))   
    # citation_issn
    highwire_press_meta_tags << meta_tag("citation_issn", print_issn(document, string_output: true))
    highwire_press_meta_tags << meta_tag("citation_issn", electronic_issn(document, string_output: true))
    # citation_isbn
    highwire_press_meta_tags << meta_tag("citation_isbn", isbn(document, string_output: true))
    # citation_keywords
    highwire_press_meta_tags << meta_tag("citation_keywords", keywords(document, string_output: true))
    # citation_language
    highwire_press_meta_tags << meta_tag("citation_language", language(document, string_output: true))
    # citation_pdf_url
    highwire_press_meta_tags << meta_tag("citation_pdf_url", pdf_url(document))
    # citation_dissertation_institution 
    highwire_press_meta_tags << meta_tag("citation_dissertation_institution", dissertation_institution(document))
    # citation_technical_report_institution  
    highwire_press_meta_tags << meta_tag("citation_technical_report_institution", report_institution(document))
    # citation_abstract_html_url
    highwire_press_meta_tags << meta_tag("citation_abstract_html_url", abstract_html_url(document))
    # citation_fulltext_html_url
    highwire_press_meta_tags << meta_tag("citation_fulltext_html_url", fulltext_html_url(document))

    return highwire_press_meta_tags.compact
  end

  private

  # We use the content resource solr fields to build the url
  def pdf_url(document)
    begin 
      # Get the position of the sequence 1 content
      content_array_position = document["sequence_ssm"].index("1")
      resource_id = document["resource_object_id_ssm"][content_array_position]
      ds_id = document['resource_ds_id_ssm'][content_array_position]
      pdf_url = "#{url_base}/resources/#{resource_id}/#{ds_id}"

      return pdf_url
    rescue
      return nil
    end
  end

  # Dates need to be of the form YYYY/MM/DD or YYYY
  # Substitution of "-" for "/" occurs
  def meta_date(document)
    date = date(document, string_output: true)

    unless date.nil?     
      # if date is YYYY-MM
      if date.match(/^\d{4}-\d{2}$/)
        # We just return the year YYYY
        date = date[0,4]
      end
      date = date.gsub("-", "/")

      return date
    end
  end 


  # disseration_institution is used only for ETDS.  
  # Bit hacky, but there is no field for institution alone, therefore we manually check the publisher for Hull 
  # and return if there is a match
  def dissertation_institution(document)
    if document_resource_type(document) == "UketdObject"
      # Local standards dictate ETDs usually in the form of Department, Institution
      publisher = publisher(document, string_output: true)

      if !publisher.nil? && publisher.downcase.include?(default_institution_name.downcase)
        return default_institution_name
      end
    end

  end

  # report_institution is used only for GenericContent#Reports.  
  # Bit hacky, but there is no field for institution alone, therefore we manually check the publisher for Hull 
  # and return if there is a match
  def report_institution(document)
    # Call HyhullHelper.resource_type_from_document(document) - Gets the Genre
    if resource_type_from_document(document) == "Report"
      # Local standards dictate Reports usually in the form of Department, Institution
      publisher = publisher(document, string_output: true)

      if !publisher.nil? && publisher.downcase.include?(default_institution_name.downcase)
        return default_institution_name
      end
    end
  end

  # abstract_html_url is only retrieved for JournalArticle and based on a url with label "abstract"
  def abstract_html_url(document)
    if document_resource_type(document) == "JournalArticle"
      return url_from_journal_urls_by_label(document, "abstract")      
    end
  end

  # fulltext_html_url is only retrieved for JournalArticle and based on a url with label "full text"
  def fulltext_html_url(document)
    if document_resource_type(document)  == "JournalArticle"
      return url_from_journal_urls_by_label(document, "full text")      
    end
  end

  # url_from_journal_urls_by_label is a method used primarily for JournalArticles
  # The method will retrieve a URL (journal_url_ssm) by matching label_text
  # against the URL label (journal_url_display_label_ssm)
  # The method errs on caution if the   journal_url_display_label_ssm/journal_url_ssm
  # array sizes don't match
  def url_from_journal_urls_by_label(document, label_text="")
    journal_urls = document["journal_url_ssm"]
    journal_url_display_labels = document["journal_url_display_label_ssm"]
 
    unless journal_urls.nil? || journal_url_display_labels.nil?
      if journal_urls.size == journal_url_display_labels.size        
        journal_url_display_labels.each_with_index do |url_display_label, i|
          if url_display_label.downcase.include?(label_text.downcase)
            return journal_urls[i]
          end
        end
      end
    end
     
  end


  %w(title author date publisher journal_title journal_volume journal_issue journal_start_page 
    journal_end_page doi print_issn isbn electronic_issn keywords language institution).each do |prop|
      define_method(prop) do |document, opts={}|
        opts = { string_output: false }.merge(opts)

        value = document[document_solr_mappings(document)[prop.to_sym]] 

        # Returns as a string
        if opts[:string_output]
          unless value.nil? 
            value = value.kind_of?(Array) ? value.join("; ") : value
          end
        end

        return value 
      end
    end

  def meta_tag(name, content)
    tag(:meta, { content: content, name: name }) unless name.nil? || content.nil?
  end

  def document_solr_mappings(document)
    # If there isn't a specific resource mapping in meta_tag_mappigns config, it uses the default config mappings
    resource_type = document_resource_type(document).to_sym
    mapping_key = meta_tag_solr_mappings.has_key?(resource_type) ? resource_type : :Default

    return meta_tag_solr_mappings[mapping_key]
  end

  # Returns the document resource type for use with solr_mappings looking
  # returns "Default" for a nil match
  def document_resource_type(document)
    document[resource_type_field].nil? ? "Default" : document[resource_type_field].kind_of?(Array) ? document[resource_type_field].first : document[resource_type_field]
  end
 
  def resource_type_field
    meta_tag_solr_mappings[:resource_type_field]
  end

  def meta_tag_solr_mappings
    return META_TAG_SOLR_MAPPINGS
  end

  def url_base
    return CONTENT_LOCATION_URL_BASE
  end

  def default_institution_name 
    return DEFAULT_INSTITUTION_NAME.nil? ? "" : DEFAULT_INSTITUTION_NAME
  end

end