# Model for a FileAsset   ActiveFedora object 
# Add Hyhull version for local requirement of rightsMetadata ds in all objects
class FileAsset < ActiveFedora::Base
  include Hydra::Models::FileAsset
  include Hyhull::FullTextDatastreamBehaviour
  
  has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata
  has_metadata name: "descMetadata", label: "Qualified DC", type: ActiveFedora::QualifiedDublinCoreDatastream do |m| end
  # assert_content_model overidden to add UketdObject custom models
  def assert_content_model
    add_relationship(:has_model, "info:fedora/hydra-cModel:commonMetadata")
    super
  end  
end