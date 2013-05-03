module Hyhull::GenericParentBehaviour
  extend ActiveSupport::Concern

  included do
    logger.info("Adding Hyhull::GenericParentBehaviour to the Hydra model")

    # GenericParent https://wiki.duraspace.org/display/hydra/Generic+aggregation+parent+content+model specifies that an object 
    # that conforms to it will take an Atomistic approach to content.  
    has_many :file_assets, property: :is_part_of, :inbound => true     
  end 

  def add_file_content(file_data)
    if file_data
      new_file_assets = []
      file_data.each do |file|
        file_asset = FileAsset.new
        file_asset.label = file.original_filename
        add_posted_blob_to_asset(file_asset, file, file.original_filename)
        file_asset.save!
        new_file_assets << file_asset      
      end      

      #Add the file_asset to self
      self.file_assets <<  new_file_assets

      #Now we should add content metadata if it exists...
      new_file_assets.each do |file_asset|
        self.update_content_metadata(file_asset, datastream_id)
      end

      # Save the changes to self..
      self.save!

      return file_assets
    else
      raise "No file_data has been specified"
    end
  end

  # Puts the contents of params[:Filedata] (posted blob) into a datastream within the given @asset
  # Sets asset label and title to filename if they're empty
  #
  # @param [FileAsset] asset the File Asset to add the blob to
  # @param [#read] file the IO object that is the blob
  # @param [String] file the IO object that is the blob
  # @return [FileAsset] file the File Asset  
  def add_posted_blob_to_asset(asset, file, file_name)
    file_name ||= file.original_filename
    asset.add_file(file, datastream_id, file_name)
  end


  def update_content_metadata(content_asset, content_ds)
    if content_asset.kind_of? ActiveFedora::Base
      pid = content_asset.pid
      size = eval "content_asset.#{content_ds}.size"
      label = eval "content_asset.#{content_ds}.dsLabel"
      mime_type = eval "content_asset.#{content_ds}.mimeType"

      format = mime_type[mime_type.index("/") + 1...mime_type.length]
   
      # Get the class_uri (Fedora model definition)
      c_model = content_asset.class.to_class_uri
      service_def = c_model[c_model.index("/") + 1...c_model.length]

      service_method = "getContent"

      self.contentMetadata.insert_resource(object_id: pid, ds_id: "content", file_size: size, url: "http://hydra.hull.ac.uk/assets/#{pid}/content", display_label: label, id: label, mime_type: mime_type, format: format, service_def: service_def, service_method: service_method)
      self.contentMetadata.save
    else
      raise "Content Metadata can only be derieved from ActiveFedora::Base objects"
    end    
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

end