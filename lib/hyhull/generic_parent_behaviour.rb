  module Hyhull::GenericParentBehaviour
  extend ActiveSupport::Concern

  included do
    logger.info("Adding Hyhull::GenericParentBehaviour to the Hydra model")

    # GenericParent https://wiki.duraspace.org/display/hydra/Generic+aggregation+parent+content+model specifies that an object 
    # that conforms to it will take an Atomistic approach to content.  
    has_many :file_assets, property: :is_part_of, :inbound => true     
  end 

  # We are overiding the standard delete from a for a GenericParent resource
  # This delete will Delete all of the Child FileAssets before deleting the parent.
  def delete
    begin    
      # file_assets
      file_assets.each do |file_asset|
        file_asset.delete
      end
      # We now reload the self to update that the child assets have been removed...
      reload()
      # Call ActiveFedora Deleted via super 
      super()
    rescue Exception => e
      raise "There was an error deleting the resource: " + e.message
    end
  end

  def add_file_content(file_data)
    begin      
      if file_data
        #Array() will return file_data in array if not already in one..
        file_data = Array(file_data)
        new_file_assets = []
        file_data.each do |file|
          begin
            pid = next_asset_pid()            
            file_asset = FileAsset.new(pid: pid)
            file_asset.label = file.original_filename

            add_posted_blob_to_asset(file_asset, file, file.original_filename)
            # Add the self.rightsMetadata to the child asset... 
            file_asset.datastreams["rightsMetadata"].content = self.rightsMetadata.content
            file_asset.save!
            new_file_assets << file_asset      
          rescue Exception => e 
            raise "There was an error creating the content: " + e.message
          end
        end      

        #Add the file_asset to self
        self.file_assets <<  new_file_assets

        #Now we should add file metadata if it is - Hyhull:ModelMethods ...
        if self.respond_to?('add_file_metadata')
          new_file_assets.each do |file_asset|
            begin               
              self.add_file_metadata(file_asset, datastream_id)
            rescue Exception => e 
              raise "There was an error adding the file metadata for #{file_asset.pid}: " + e.message
            end
          end
        else
          logger.info("Hyhull::GenericParentBehaviour #{self.class.to_s} does not include tje add_file_metadata method")
        end

        # Save the changes to self..
        self.save!
        new_file_assets_labels =  new_file_assets.map{|asset| asset.label }
        return true, new_file_assets, "The following files have been added sucessfully to #{self.pid}: #{new_file_assets_labels}"
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

      if self.pid == resource_object_id
        raise "File object identifer matches parent identifier, not a valid GenericParent parent-child resource"
      else
        begin 
          resource = FileAsset.find(resource_object_id)
          if self.file_assets.include?(resource)
            # asset object itself...
            resource.delete

            # Reload self to ensure that the removed asset is persisted to local object
            self.reload

            #Now delete the resource from the contentMetadata ds
            self.contentMetadata.remove_resource(index)

            #Save changes to self
            self.save!

            return true, resource_object_id, "File #{resource_display_label} (#{resource_object_id}) deleted sucessfully"

          else
            raise "Delete aborted: The File #{resource_object_id} (#{resource_object_id}) does exist within the parent #{self.pid} FileAssets list." 
          end 

        rescue Exception => e 
          raise "There was an error deleting the content: " + e.message
        end
      end
    rescue Exception => e 
      return false, "", "Error: #{e.message}"
    end
    
  end

  # Puts the contents of params[:Filedata] (posted blob) into a datastream within the given @asset
  # Sets asset label and title to filename if they're empty
  # DEFAULT_CHECKSUM_TYPE defined in config/initializers/hyhull.rb
  #
  # @param [FileAsset] asset the File Asset to add the blob to
  # @param [#read] file the IO object that is the blob
  # @param [String] file the IO object that is the blob
  # @return [FileAsset] file the File Asset  
  def add_posted_blob_to_asset(asset, file, file_name)
    file_name ||= file.original_filename 
    options = {:label=>file_name, :dsid => datastream_id, :checksumType => DEFAULT_CHECKSUM_TYPE}
    ds_id  = asset.add_file_datastream(file, options)
  end

  #Override this if you want to specify the datastream_id (dsID) for the created blob
  def datastream_id
    "content"
  end

  # assert the genericParent cModel.    
  def assert_content_model
    add_relationship(:has_model, "info:fedora/hydra-cModel:genericParent")
    super
  end

  # Calculates the next available child asset pid (based on pid+alpha sequence)
  #
  # @return [String] the next available pid
  #
  # @example: next_asset_pid("hull:3108") => "hull:3108a" if no child asset previously existed
  def next_asset_pid   
    id_array = self.file_assets.map{ |asset| asset.id }.sort
    logger.debug("existing siblings - #{id_array}")
    if id_array.empty?
      return "#{self.id}a"
    else
      if id_array[-1].match /[a-zA-Z]$/
        return "#{self.id}#{id_array[-1].split('')[-1].succ}"
      else
        return nil
      end
    end
  end

end