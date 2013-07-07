module Hyhull::GenericContentBehaviour 
  extend ActiveSupport::Concern

  included do
    logger.info("Adding Hyhull::GenericContentBehaviour to the Hydra model")
    # GenericContent https://wiki.duraspace.org/display/hydra/Generic+aggregation+parent+content+model specifies that an object 
    # that conforms to it will take a compound approach to the addition of content.  
  end


  def add_file_content(file_data)
    begin      
      if file_data
        #Array() will return file_data in array if not already in one..
        file_data = Array(file_data)
        new_asset_datastreams = []
        file_data.each do |file|
          begin
          	label = file.original_filename
            options = {:label=>label, :prefix=>'content', :checksumType => 'MD5'}
            ds_id  = self.add_file_datastream(file, options)
            new_asset_datastreams << ds_id
          rescue Exception => e 
            raise "There was an error creating the content: " + e.message
          end
        end

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
        new_file_ds_labels = new_asset_datastreams.map{|ds_id| self.[ds_id].label }
        return true, new_file_ds_labels, "The following files have been added sucessfully to #{self.pid}: #{new_file_assets_labels}"
      else
        raise "No file_data has been specified"
      end

    rescue Exception => e 
      return false, [], "Error: #{e.message}"
    end
  end
end


