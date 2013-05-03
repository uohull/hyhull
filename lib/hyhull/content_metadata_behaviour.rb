module Hyhull::ContentMetadataBehaviour
  extend ActiveSupport::Concern

  included do
    logger.info("Adding Hyhull::ContentMetadataBehaviour to the Hydra model")

    # Include Hyhulls::Datastream::ContentMetadataBehaviouretadata for information about contents stroed against objects
    has_metadata name: "contentMetadata", type: Hyhull::Datastream::ContentMetadata, versionable: true

    delegate :sequence, to: "contentMetadata"
    delegate :display_label, to: "contentMetadata"
    delegate :resource_object_id, to: "contentMetadata"
    delegate :resource_ds_id, to: "contentMetadata" 
    delegate :content_id, to: "contentMetadata"     
  end 
end