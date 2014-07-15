module Hyhull::Solr::DocumentExt
  extend ActiveSupport::Concern


  # Just a convenience method that returns the 'main asset' for the resource - In hyhull this is the asset with sequence no 1.
  # However contentmetadata could specify an attribute to define this...
  def main_asset
    assets = resource_assets
    unless assets.nil?
      return assets["1"] 
    end
  end

  def resource_assets
    resource_assets ={}

     asset_count = asset_sequence.size
     
     if (asset_object_id.size != asset_count || asset_ds_id.size != asset_count)
        return nil
     else
       asset_sequence.each_with_index do |seq, i|       
         resource_assets[seq] = { 
                                                 mimetype: asset_mime_type[i], 
                                                 size: asset_size[i], 
                                                 format: asset_format[i],
                                                 relative_path: relative_asset_path[i]
                                            }
       end
     end
     resource_assets
  end

  #Will return the ISO 639-2 three letter language code for the resource 
  def language_code
    if self.has? "language_code_ssm"
      return self.get("language_code_ssm")
    else
      if self.has? "language_text_ssm"
        begin
          language = Hyhull::Utils::Language.find_by_name(self.get("language_text_ssm"))
          return language.code
        rescue
          # Can't find match for language text
        end
      end      
    end
  end

  def main_asset_uri
    return self.main_asset[:relative_path].nil? ? "" : "#{base_url}#{self.main_asset[:relative_path]}"
  end

  def full_resource_uri
    return "#{base_url}#{resource_path}"
  end

  def resource_path
    "/#{resource_controller_name}/#{self.id}"
  end

  # Returns the description for a resource (could come from two places)
  def description
    if self.has?  "abstract_ssm"
      return self.get "abstract_ssm"
    elsif self.has? "description_ssm"
      return self.get "description_ssm"
    end
  end

  # Resource type ie.. Text, Moving image etc...
  def resource_type
    return self.get("type_of_resource_ssm")
  end

  private

  def relative_asset_path
    asset_object_id.map.with_index { |asset_object_id, i|  "/#{downloads_controller_name}/#{asset_object_id}/#{asset_ds_id[i]}" }
  end

  def asset_sequence
    return self["sequence_ssm"] if self.has? "sequence_ssm"
  end

  def asset_object_id
    return self["resource_object_id_ssm"] if self.has? "resource_object_id_ssm"
  end

  def asset_ds_id
    return self["resource_ds_id_ssm"] if self.has? "resource_ds_id_ssm"
  end

  def asset_mime_type
    return self["content_mime_type_ssm"] if self.has? "content_mime_type_ssm"
  end

  def asset_size
    return self["content_size_ssm"] if self.has? "content_size_ssm"
  end

  def asset_format
   return self["content_format_ssm"] if self.has? "content_format_ssm"
  end

  def resource_controller_name
    "resources"
  end

  def downloads_controller_name
    "assets"
  end


  def base_url
    CONTENT_LOCATION_URL_BASE.nil? ? "localhost" : CONTENT_LOCATION_URL_BASE 
  end


end