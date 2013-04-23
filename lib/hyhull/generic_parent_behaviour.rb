module Hyhull::GenericParentBehaviour
  extend ActiveSupport::Concern

  included do
    logger.info("Adding Hyhull::GenericParentBehaviour to the Hydra model")

    # GenericParent https://wiki.duraspace.org/display/hydra/Generic+aggregation+parent+content+model specifies that an object 
    # that conforms to it will take an Atomistic approach to content.  
    has_many :file_assets, property: :is_part_of, :inbound => true     
  end 


  def add_file_content
    if params.has_key?(:Filedata)
      @file_assets = []
      params[:Filedata].each do |file|
        @file_asset = FileAsset.new
        @file_asset.label = file.original_filename
        add_posted_blob_to_asset(@file_asset, file, file.original_filename)
        @file_asset.save!
        @file_assets << @file_asset
      end      
      return @file_assets
    else
      raise "No :filedata has been specified"
    end
  end

  # assert the genericParent cModel.  
  def assert_content_model
    add_relationship(:has_model, "info:fedora/hydra-cModel:genericParent")
    super
  end

end