module HyhullHelper
  
  #########################################################
  #                                                       #
  # Blacklight Helper over-rides                          #
  # * Overrides methods within BlacklightHelperBehavior   #
  #                                                       #
  #########################################################

  def application_name
    'Digital Repository'
  end

  # Default seperator change
  def field_value_separator
    '; '
  end

  #######################################################
  # - End of Blacklight Helper over-rides               #
  #######################################################

  # Return the Hyhull version - see config/application.rb for origin of config.version
  def hyhull_version
    if Hyhull::Application.config.respond_to? :version
      return Hyhull::Application.config.version.to_s.chop.html_safe
    else
      return ""
    end
  end

  # Provides a edit_link to a resource based upon the data within the SolrDocument
  def edit_resource_link(document)
    active_fedora_model = model_from_document(document)
    unless active_fedora_model.nil?
      return link_to "Edit resource", controller: active_fedora_model.tableize, action: "edit", id: document.id 
    end
  end

  # Provides a link to the Show page for a resource
  def show_resource_link(id)
    return link_to "Show resource", controller: "catalog", action: "show", id: id
  end

  # Returns the ActiveFedora model from the Solr document
  def model_from_document(document)
    active_fedora_model = document["active_fedora_model_ssi"]
  end

  # Returns the Resource type/Genre from the Solr document
  def resource_type_from_document(document)
    resource_type = ""
    resource_type = document["genre_ssm"] unless document["genre_ssm"].nil?
    resource_type = resource_type.is_a?(Array) ?  resource_type.first : resource_type
  end

  #This helper method will create a list of downloadable assets for a 
  #resource.
  #It also adds a google event tracker call to the link, in the form of:-
  #onClick="_gaq.push(['_trackEvent','Downloads', 'Resource title', 'PID/DsID'])
  def display_resources(document)
    resources = ""

    if document.has?("resource_object_id_ssm") && document["resource_object_id_ssm"].size > 0 
      resources_size = document["resource_object_id_ssm"].size
      
      resources = <<-EOS
        <fieldset id="assets">
        <legend><h3>#{pluralize_string(resources_size, "Download")}</h3></legend>
        <div id="asset-list">
      EOS

      display_label = document["resource_display_label_ssm"] if document.has?("resource_display_label_ssm")
      asset_object_id = document["resource_object_id_ssm"] if document.has?("resource_object_id_ssm")
      asset_ds_id = document["resource_ds_id_ssm"] if document.has?("resource_ds_id_ssm")
      asset_mime_type = document["content_mime_type_ssm"] if document.has?("content_mime_type_ssm")
      asset_format = document["content_format_ssm"] if document.has?("content_format_ssm")
      asset_file_size = document["content_size_ssm"] if document.has?("content_size_ssm")
      asset_sequence = document["sequence_ssm"] if document.has?("sequence_ssm")

      sequence_hash = {}
      asset_sequence.each_with_index{|v,i| sequence_hash[v.to_i] = i }

      sequence_hash.keys.sort.each do |seq| 
        i = sequence_hash[seq]
        resources << <<-EOS
          <div id="download" class="clearfix">
            <div class="pull-left"> 
              <div id="download_image" class="#{download_image_class_by_mime_type(asset_mime_type[i].to_s)}" ></div>
              <a href="/assets/#{asset_object_id[i].to_s}/#{asset_ds_id[i].to_s}" onClick="_gaq.push(['_trackEvent','Downloads', '#{asset_object_id[i].to_s}/#{asset_ds_id[i].to_s}', '#{document_title(document)}']);">#{display_label[i].to_s}</a> 
        EOS

        resources << <<-EOS
           <div id="file-size">(#{get_friendly_file_size(asset_file_size[i].to_s) unless asset_file_size.nil?} #{asset_format[i].to_s} )
        EOS

        # #If the content is a KMZ or a KML file and less then 3MB...
        if (asset_mime_type[i].eql?("application/vnd.google-earth.kmz") || asset_mime_type[i].eql?("application/vnd.google-earth.kml+xml"))
           if asset_file_size[i].to_i > 0 && asset_file_size[i].to_i < 3145728
             # And if the document is public readable... We display a link to the Google maps View of the map - Google maps need the KML/KMZ to be public accessible...
             if is_public_read(document)
               resources << <<-EOS
                 <div id="view-map-link">
                 <a href="/assets/map_view/#{asset_object_id[i].to_s}/#{asset_ds_id[i].to_s}">View as map<a></div>
               EOS
             end
           end
        end

        resources << <<-EOS
            </div>
          </div>

          <div class="pull-right ">
            <span class="label label-alt">
              <i class="icon-white icon-download"></i>
              <a href="/assets/#{asset_object_id[i].to_s}/#{asset_ds_id[i].to_s}" onClick="_gaq.push(['_trackEvent','Downloads', '#{asset_object_id[i].to_s}/#{asset_ds_id[i].to_s}', 'Download">Download</a>
            </span>
          </div>
         </div>
        EOS
      end

      resources << <<-EOS
        </div>
       </fieldset>
      EOS
    end
    resources.html_safe
  end

  def set_children_link(document)
    model = model_from_document(document)
    if model == "DisplaySet" || model == "StructuralSet"
      link_to "Show collection members", "/resources/?f%5Bis_member_of_ssim%5D%5B%5D=info:fedora/#{document.id}&results_view=true" 
    end
  end

  def display_resource_permissions(resource, permission_ds)
    groups = resource.datastreams[permission_ds].groups

    unless groups.nil?
      permissions = <<-EOS
         <fieldset>
           <dl>
           <dt><strong>Default permissions</strong></dt><dd></dd>
      EOS
      groups.each do |group|
        group_permission = group[1].to_s
      
        case group_permission
        when "read"
          group_display = "Read and download"
        when "edit"
          group_display = "Edit"
        when "discover"
          group_display = "Search and discover" 
        else
          group_display = group_permission       
        end

        permissions << <<-EOS
            <dt>
             #{group[0]}
            </dt>
            <dd class="dd_text">
              #{group_display}
            </dd>
        EOS
      end 
    end
    permissions << <<-EOS
          </dl>
         </fieldset>
     EOS
    permissions.html_safe
  end


  def breadcrumb_trail_for_set(pid)
    #Objects ids are stored as "info:fedora/hull:3374" in tree so we need to append this
    breadcrumb = ""
    structural_set_tree = StructuralSet.tree    
    current_node = ""   
    
    structural_set_tree.each do |node|
      if node.name == pid
        current_node = node
        break
      end
    end

    if current_node != ""     
      parentage_sets = current_node.parentage.reverse
      parentage_sets.each do |set| 
        pid = set.name
        name = set.content
        breadcrumb << name if parentage_sets.first == set
        breadcrumb << link_to(name , structural_set_path(pid)) if parentage_sets.first != set
        breadcrumb << " &gt; " if parentage_sets.last != set
      end
    end

    breadcrumb.html_safe
  end


  #Returns a pluralized string
  def pluralize_string(count, singular)
    pluralize(count,singular)[2..-1]
  end

  def download_image_class_by_mime_type(mime_type)    
    image_class = case mime_type
    when "application/pdf"
      "pdf-download"
    when "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "doc-download"
    when "image/gif", "image/jpg", "image/jpeg", "image/bmp"
      "img-download"
    when "video/avi", "video/mpeg", "video/quicktime", "video/x-ms-wmv"
      "vid-download"
    when "audio/aiff", "audio/midi", "audio/mpeg", "audio/x-pn-realaudio", "audio/wav"
      "sound-download"
    when "application/vnd.openxmlformats-officedocument.presentationml.presentation", "application/vnd.ms-powerpoint"
      "presentation-download"
    when "application/excel", "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "spreadsheet-download"
    when "application/zip"
      "zip-download"
    when "application/vnd.google-earth.kmz", "application/vnd.google-earth.kml+xml"
      "kmlz-download"
    else
      "generic-download"
    end
  end

  # display_field
  def display_field(document, solr_fname, label_text='', html_class)
    display_dt_dd_element(label_to_display(label_text), solr_field_value(document, solr_fname), html_class)
  end

  def display_text_area_field(document, solr_fname, label_text='', html_class)
    display_dt_dd_element(label_to_display(label_text), simple_format(solr_field_value(document, solr_fname)), html_class)
  end

  def display_truncated_field(document, solr_fname, label_text='', html_class, truncate_length)
     display_dt_dd_element(label_to_display(label_text), truncate(solr_field_value(document, solr_fname), length: truncate_length), html_class)
  end

  # display_boolean_field value as Yes/No
  def display_boolean_field(document, solr_fname, label_text='', html_class)
    unless solr_field_value(document, solr_fname).blank?
      boolean_value = solr_field_value(document, solr_fname) == "true" ? true : false
      display_dt_dd_element(label_to_display(label_text), human_boolean(boolean_value), html_class)
    end
  end

  def display_date_field(document, solr_fname, label_text='', html_class)
     display_dt_dd_element(label_to_display(label_text), display_friendly_date(solr_field_value(document, solr_fname)), html_class)
  end

  def display_field_as_link(document, solr_fname, label_text='', link_text, html_class)
    display_dt_dd_element(label_to_display(label_text), link(solr_field_value(document, solr_fname),  link_text) , html_class)
  end

  def display_encoded_html_field(document, solr_fname, label_text='', html_class)
    display_dt_dd_element(label_to_display(label_text), return_unencoded_html_string(solr_field_value(document, solr_fname)), html_class)
  end

  # Use to provide a DOI link within the standard dd/dt field elements
  def doi_resolver_field(document, doi_fname, label_text='', html_class)
    doi = solr_field_value(document, doi_fname)
    if doi.length > 0      
      display_dt_dd_element(label_to_display(label_text), link(doi_resolver_link(doi), doi), html_class)
    end
  end

  def geo_data_from_solr_doc(document)
    label = solr_field_value(document, "location_label_ssm")
    coordinates_type = solr_field_value(document, "location_coordinates_type_ssm")
    coordinates = solr_field_value(document, "location_coordinates_ssm")
    return { label: label, coordinates_type: coordinates_type, coordinates: coordinates }
  end

  def display_resource_thumbnail(document)
    content_tag(:div, nil, class: thumbnail_class_from_document(document), id: "cover-art")
  end

  def thumbnail_class_from_document(document)
    resource_type = resource_type_from_document(document)

    thumbnail_class = case resource_type
    when "Examination paper"
      "exam-thumb"
    when "Meeting papers or minutes"
      "calendar-thumb"
    when "Dataset"
      "dataset-thumb"
    when "Presentation"
      "presentation-thumb"
    when "Policy or procedure", "Regulation"
      "policy-thumb"
    when "Photograph", "Artwork"
      "image-thumb"
    when "Thesis or dissertation"
      "thesis-thumb"
    when "Handbook"
      "handbook-thumb"
    when "Book"
      "domesday-thumb"
    else
      "generic-thumb"
    end

  end

  # #{state}_resource_state?(document) method for checking the state of solr document based 
  # upon the resource_state solr field.  At present the following states exist:-
  # proto, qa, published, hidden, deleted
  ["proto", "qa", "published", "hidden", "deleted"].each do |state|
    define_method("#{state}_resource_state?") do |doc|
       solr_field_value(doc, resource_state_fname) == state
    end
  end


  private

  def document_title(document)
    return solr_field_value(document, "title_tesim")
  end

  def display_dt_dd_element(dt_value, dd_value, html_class)
    # Only display if length > 0 and value isn't <p></p> (empty simple_format default)
    if dd_value.length > 0 && dd_value != "<p></p>"
      content_tag(:dt, dt_value, :class => blacklight_dd_class(html_class)) <<
      content_tag(:dd, dd_value, :class => blacklight_dd_class(html_class))
    end
  end

    
  def solr_field_value(document, solr_fname)
    if document.has? solr_fname
      return render_index_field_value(:document => document, :field => solr_fname)
    else 
      return ""
    end
  end
    
  def label_to_display(label)
    if label.to_s.length > 0
      return label
    else
      return ""
    end
  end

  def blacklight_dd_class(dd_class)
    if dd_class.to_s.length > 0
      return "blacklight-#{dd_class}"
    else
      return ""
    end
  end

  def return_unencoded_html_string(value) 
    value.to_s.gsub(/&lt\;/, "<").gsub(/&gt\;/, ">").html_safe
  end

  def link(url, text) 
    link_to text.to_s, url.to_s
  end

  def doi_resolver_link(doi="")
   return "#{DOI_RESOLVER_SERVICE_URL}#{doi}"
  end

  # Checks whether a document/resource is public readable...
  def is_public_read(document)
    is_public_read = false
    read_access_group = document.get("read_access_group_ssim")
    unless read_access_group.blank? 
      if read_access_group.is_a? Array
        is_public_read = read_access_group.include? "public"
      else
        is_public_read = read_access_group == "public"
      end
    end
    return is_public_read
  end

  def get_friendly_file_size(size_in_bytes_str)
    text = ""
    if size_in_bytes_str.length > 0
      begin
        size_in_bytes = Float(size_in_bytes_str)
        text = bits_to_human_readable(size_in_bytes).to_s
      rescue ArgumentError
        text = ""
      end
    end
    text  
  end

  def bits_to_human_readable(num)
   ['bytes','KB','MB','GB','TB'].each do |x|
    if num < 1024.0
     return "#{num.to_i} #{x}"
    else
     num = num/1024.0
     end
    end
  end


  # Pass through a string date in the format of YYYY-MM-DD/YYYY-MM/YYYY and it will return a human readable version
  def display_friendly_date(date)
    display_date = date
    begin
      if date.match(/^\d{4}-\d{2}$/)
        display_date = Date.parse(to_long_date(date)).strftime("%B") + " " + Date.parse(to_long_date(date)).strftime("%Y")
      elsif date.match(/^\d{4}-\d{2}-\d{2}$/)
        display_date = Date.parse(date).day().to_s + " " + Date.parse(date).strftime("%B") + " " + Date.parse(date).strftime("%Y")
      end
    rescue
      # Just rescue an issue with parsing the date...
    end 
    
    return display_date
  end

   #Utility method used to get long version of a date (YYYY-MM-DD) from short form (YYYY-MM) - Defaults 01 for unknowns - Exists in hull_model_methods too
  def to_long_date(flexible_date)
    full_date = ""
    if flexible_date.match(/^\d{4}$/)
            full_date = flexible_date + "-01-01"
    elsif flexible_date.match(/^\d{4}-\d{2}$/)
            full_date = flexible_date + "-01"
    elsif flexible_date.match(/^\d{4}-\d{2}-\d{2}$/)
            full_date = flexible_date
    end
    return full_date
  end

  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end
   
  # Solr field name used for the resource_state
  def resource_state_fname
    "_resource_state_ssi"
  end 

end