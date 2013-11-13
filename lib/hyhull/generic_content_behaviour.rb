module Hyhull::GenericContentBehaviour 
  extend ActiveSupport::Concern
  include Hyhull::FullTextDatastreamBehaviour

  included do
    logger.info("Adding Hyhull::GenericContentBehaviour to the Hydra model")
    # GenericContent https://wiki.duraspace.org/display/hydra/Generic+aggregation+parent+content+model specifies that an object 
    # that conforms to it will take a compound approach to the addition of content.  
  end

  # DEFAULT_CHECKSUM_TYPE defined in config/initializers/hyhull.rb
  def add_file_content(file_data)
    begin      
      if file_data
        #Array() will return file_data in array if not already in one..
        file_data = Array(file_data)
        new_asset_datastreams = []
        file_data.each do |file|
          begin
          	label = file.original_filename
            options = {:label=>label, :prefix=>'content', :checksumType => DEFAULT_CHECKSUM_TYPE}
            ds_id  = self.add_file_datastream(file, options)
            new_asset_datastreams << ds_id
          rescue Exception => e 
            raise "There was an error creating the content: " + e.message
          end
        end
        
        # Persist the new file datastreams to Fedora
        self.save! 

        #Now we should add file metadata if it is - Hyhull:ModelMethods ...
        if self.respond_to?('add_file_metadata')
          new_asset_datastreams.each do |ds_id|
            begin               
              self.add_file_metadata(self, ds_id)
            rescue Exception => e 
              raise "There was an error adding the file metadata for #{file_asset.pid} datastream #{ds_id}: " + e.message
            end
          end
        else
          logger.info("Hyhull::GenericContentBehaviour #{self.class.to_s} does not include the add_file_metadata method")
        end

        # Save the changes to self..
        self.save!
        new_file_ds_labels = new_asset_datastreams.map{|ds_id| self.datastreams[ds_id].label }
        return true, new_asset_datastreams, "The following files have been added sucessfully to #{self.pid}: #{new_file_ds_labels}"
      else
        raise "No file_data has been specified"
      end

    rescue Exception => e 
      return false, [], "Error: #{e.message}"
    end
  end

  def delete_by_content_metadata_resource_at(index)
    begin 
      resource_object_id = self.contentMetadata.resource(index).resource_object_id[0]
      resource_ds_id = self.contentMetadata.resource(index).resource_ds_id[0]
      resource_display_label = self.contentMetadata.resource(index).display_label[0]

      if self.pid != resource_object_id
        raise "File object identifer does not match self.pid, not a valid GenericContent compound resource"
      else
        begin 
          if self.datastreams.include?(resource_ds_id)

            # delete the asset ds
            self.datastreams[resource_ds_id].delete

            #Now delete the resource from the contentMetadata ds
            self.contentMetadata.remove_resource(index)

            #Save changes to self
            self.save!

            return true, "#{resource_object_id}##{resource_ds_id}", "File #{resource_display_label} (#{resource_ds_id}) deleted sucessfully"

          else
            raise "Delete aborted: The File #{resource_display_label} does exist within the #{self.pid} at the specified datastream #{resource_ds_id}." 
          end 

        rescue Exception => e 
          raise "There was an error deleting the content: " + e.message
        end
      end
    rescue Exception => e 
      return false, "", "Error: #{e.message}"
    end    
  end

  # A helper method that returns an array of content datastreams
  #
  def content_datastreams 
    ds_array = []
    # Iterate through the datastreams and build ds_id array..
    self.datastreams.each_key do |key| ds_array << key  end     
    content_ds = ds_array.select do |s| if s != 'contentMetadata' then s.include? 'content' end  end

    content_ds
  end

  def generate_dsid(prefix="DS")
    keys = datastreams.keys
    return prefix unless keys.include?(prefix)
    matches = datastreams.keys.map {|d| data = /^#{prefix}(\d+)$/.match(d); data && data[1].to_i}.compact
    val = matches.empty? ? 1 : matches.max + 1
    format_dsid(prefix, val)
  end

end


