module Hyhull
  module Datastream
    # Hyhull implementation of DefaultObjectRights follows the standard RightsMetadata DS model but doesn't need indexing
    # TODO Move to hydra-head implementation PolicyObject behaviour
    class DefaultObjectRights < Hydra::Datastream::RightsMetadata
      #Overrides to_solr to remove indexing of this DS
      def to_solr(obj)
        obj
      end
    end
  end
end