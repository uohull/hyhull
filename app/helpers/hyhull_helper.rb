module HyhullHelper

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
        <legend>#{pluralize_string(resources_size, "Download")}</legend>
        <div id="asset-list">
      EOS

      resource_title = document["title_ssm"].first if document.has?("title_ssm")
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
          <div id="download"> 
            <div id="download_image" class="#{download_image_class_by_mime_type(asset_mime_type[i])}" ></div>
             <a href="/assets/#{asset_object_id[i]}/#{asset_ds_id[i]}" onClick="_gaq.push(['_trackEvent','Downloads', '#{asset_object_id[i]}/#{asset_ds_id[i]}', '#{resource_title}']);">#{display_label[i]}</a> 
        EOS

        resources << <<-EOS
           <div id="file-size">(#{get_friendly_file_size(asset_file_size[i])} #{asset_format[i]})
        EOS

        # #If the content is a KMZ or a KML file and less then 3MB...
        # if (asset_mime_type[i].eql?("application/vnd.google-earth.kmz") || asset_mime_type[i].eql?("application/vnd.google-earth.kml+xml"))
        #   if asset_file_size[i].to_i > 0 && asset_file_size[i].to_i < 3145728
        #     # And if the document is public readable... We display a link to the Google maps View of the map - Google maps need the KML/KMZ to be public accessible...
        #     if is_public_readable(document)
        #       resources << <<-EOS
        #         <div id="view-map-link">
        #         <a href="/google_map.html?object_id=#{asset_object_id[i]}&asset_ds_id=#{ds_id[i]}" target="_blank">View as map<a></div>
        #       EOS
        #     end
        #   end
        # end

        resources << <<-EOS
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

  # display_field
  def display_field(document, solr_fname, label_text='', html_class)
     display_dt_dd_element(label_to_display(label_text), solr_field_value(document, solr_fname), html_class)
  end

  def display_field_as_link(document, solr_fname, label_text='', link_text, dd_class)
    display_dt_dd_element(label_to_display(label_text), link(solr_field_value(document, solr_fname),  link_text) , html_class)
  end

  def display_encoded_html_field(document, solr_fname, label_text='', html_class)
    display_dt_dd_element(label_to_display(label_text), return_unencoded_html_string(solr_field_value(document, solr_fname)), html_class)
  end

  private

  def display_dt_dd_element(dt_value, dd_value, html_class)
    if dd_value.length > 0
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

end