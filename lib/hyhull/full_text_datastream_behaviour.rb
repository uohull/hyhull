module Hyhull::FullTextDatastreamBehaviour
  extend ActiveSupport::Concern

  included do
    logger.info("Adding Hyhull::FullTextDatastreamBehaviour to the Hydra model")
     has_file_datastream "fullText", label: "Full text representation", versionable: false
  end

end  