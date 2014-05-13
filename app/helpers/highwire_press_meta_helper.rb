module HighwirePressMetaHelper

  def meta_tags(document)
    meta_tags = Array.new

    # citation_title 
    meta_tags << meta_tag("citation_title", title(document).first)

    # citation_author
    author(document).each { |name| meta_tags << meta_tag("citation_author", name) }
   
    # citation_date
    meta_tags << meta_tag("citation_date", date(document).first.gsub("-", "/"))

    # citation_publisher
    meta_tags << meta_tag("citation_publisher", publisher(document).first)

    # citation_journal_title
    meta_tags << meta_tag("citation_journal_title", journal_title(document).first)

    # citation_volume
    meta_tags << meta_tag("citation_volume", journal_volume(document).first)

    # citation_issue
    meta_tags << meta_tag("citation_issue", journal_issue(document).first)

    # citation_firstpage
    meta_tags << meta_tag("citation_firstpage", journal_start_page(document).first)

    # citation_lastpage
    meta_tags << meta_tag("citation_lastpage", journal_end_page(document).first)

    # citation_doi
    meta_tags << meta_tag("citation_doi", doi(document).first)
   
    # citation_issn
    meta_tags << meta_tag("citation_issn", print_issn(document).first)
    meta_tags << meta_tag("citation_issn", electronic_issn(document).first)

    # citation_keywords
    meta_tags << meta_tag("citation_keywords", keywords(document).map{ |t| t + "\; " }.join)

    # citation_language
    meta_tags << meta_tag("citation_language", language(document))

    # citation_pdf_url
    meta_tags << meta_tag("citation_pdf_url", pdf_url(document))

    return meta_tags
        
  end


  private

  %w(title author date publisher journal_title journal_volume journal_issue journal_start_page 
    journal_end_page doi print_issn electronic_issn keywords language).each do |prop|
      define_method(prop) do |document|
        return document[document_solr_mappings(document)[prop.to_sym]] 
      end
    end

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

  def meta_tag(name, content)
    tag(:meta, { content: content, name: name }) unless name.nil? || content.nil?
  end

  def document_solr_mappings(document)
    meta_tag_solr_mappings[document_resource_type(document).to_sym]
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

end