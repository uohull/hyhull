module Hyhull::ContentMetadataBehaviour
  extend ActiveSupport::Concern

  included do
    logger.info("Adding Hyhull::ContentMetadataBehaviour to the Hydra model")

    # Include Hyhulls::Datastream::ContentMetadataBehaviouretadata for information about contents stroed against objects
    has_metadata name: "contentMetadata", label: "Content metadata", type: Hyhull::Datastream::ContentMetadata, versionable: true

    delegate :sequence, to: "contentMetadata"
    delegate :resource_display_label, to: "contentMetadata"
    delegate :resource_object_id, to: "contentMetadata"
    delegate :resource_ds_id, to: "contentMetadata" 
    delegate :content_id, to: "contentMetadata"     
  end 

  # Adds file information to self.contentMetadata
  # based upon the Content objects content datastream 
  # Returns the position of the resource in the contentMetadata
  def add_content_metadata(content_asset, content_ds)
    if content_asset.kind_of? ActiveFedora::Base
      pid = content_asset.pid
      size = content_asset.datastreams[content_ds].size
      label = content_asset.datastreams[content_ds].dsLabel
      mime_type = content_asset.datastreams[content_ds].mimeType
      content_id = label

      #Get the checksum and type from fedora and store in contentMetadata...
      checksum_type = content_asset.datastreams[content_ds].checksumType
      checksum = content_asset.datastreams[content_ds].checksum
      
      format = mime_type[mime_type.index("/") + 1...mime_type.length]
   
      # Get the class_uri (Fedora model definition)
      c_model = content_asset.class.to_class_uri
      service_def = c_model[c_model.index("/") + 1...c_model.length]

      service_method = "getContent"

      self.contentMetadata.insert_resource(object_id: pid, ds_id: content_ds, file_size: size, file_id: content_id, url: "http://hydra.hull.ac.uk/assets/#{pid}/content", display_label: label, id: label, mime_type: mime_type, format: format, service_def: service_def, service_method: service_method, :checksum => checksum, :checksum_type => checksum_type)
      self.contentMetadata.save

      resource_no = self.contentMetadata.resource.size - 1

      return resource_no

    else
      raise "Content Metadata can only be derived from ActiveFedora::Base objects"
    end    
  end


  # Enables the caller to retrieve key content metadata fields by the sequence no
  def get_resource_metadata_by_sequence_no(sequence_no)
    index = self.contentMetadata.sequence.find_index(sequence_no)

    unless index.nil?
      asset_id = self.contentMetadata.resource_object_id[index]
      datastream_id = self.contentMetadata.resource_ds_id[index]
      display_label = self.contentMetadata.resource_display_label[index]
      mime_type = self.contentMetadata.content_mime_type[index]
      content_size = self.contentMetadata.content_size[index]
      return {:asset_id => asset_id, :datastream_id => datastream_id, :display_label => display_label, :mime_type => mime_type, :content_size => content_size}
    end
  end

end