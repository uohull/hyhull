# lib/hyhull/models/harvesting_set.rb
# Object model for the hyhull HarvestingSet
module Hyhull
  module Models
    module HarvestingSet
      extend ActiveSupport::Concern
      
      included do      
        include Hyhull::ModelMethods
        include Hyhull::Models::SetTreeBehaviour 

        has_metadata name: "descMetadata", label: "MODS metadata", type: Hyhull::Datastream::ModsSet
        has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata
       
        delegate_to :descMetadata, [:title, :description, :resource_status, :genre, :type_of_resource, :primary_display_url, :identifier], unique: true
          
        belongs_to :parent, property: :is_member_of, :class_name => "HarvestingSet"
        has_many :children, property: :is_member_of, :class_name => "HarvestingSet"
        has_many :harvestable_resources, property: :is_member_of_collection,  :class_name => "ActiveFedora::Base"

   
        # Override the Hyhull:ModelMethods
        # Adds metadata about the depositor to the asset
        # Most important behavior: This version will NOT set rightsMetadata based on user_id (this is handled by set_rightsMetadata)
        # @param [String, #user_key] depositor
        #
        def apply_depositor_metadata(depositor, depositor_email)
          prop_ds = self.datastreams["properties"]

          depositor_id = depositor.respond_to?(:user_key) ? depositor.user_key : depositor

          if prop_ds
            prop_ds.depositor = depositor_id unless prop_ds.nil?
            prop_ds.depositor_email = depositor_email unless prop_ds.nil?
          end
          
          return true
        end

        def apply_genre
          self.genre = "Harvesting set"
        end
      
      end

      module ClassMethods
        # tree functionality is serviced by Hyhull::Models::SetTreeBehaviour 
        def tree
          tree_root = build_tree("hull:rootHarvestingSet", "info\\:fedora\\/hull-cModel\\:harvestingSet")
        end
      end

      # assert_content_model overidden to add UketdObject custom models
      def assert_content_model
        add_relationship(:has_model, "info:fedora/hydra-cModel:commonMetadata")
        super
      end  

    end 
  end
end
