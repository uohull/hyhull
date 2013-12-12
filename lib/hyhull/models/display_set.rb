# lib/hyhull/models/structural_set.rb
# Object model for the hyhull structural_set
module Hyhull
  module Models
    module DisplaySet
      extend ActiveSupport::Concern
      
      included do      
        include Hyhull::ModelMethods
        include Hyhull::Models::Permissions
        include Hyhull::Models::SetTreeBehaviour 

        after_initialize :apply_genre
        before_create :set_rights_metadata 

        has_metadata name: "descMetadata", label: "MODS metadata", type: Hyhull::Datastream::ModsSet

        has_attributes :title, :description, :resource_status, :genre, :type_of_resource, :primary_display_url, :identifier, datastream: :descMetadata, multiple: false
          
        belongs_to :apo, property: :is_governed_by, :class_name => "DisplaySet"
        has_many :children, property: :is_member_of, :class_name => "ActiveFedora::Base"
       
        validates :title, presence: true
        # The root display set do not have display_set parent...
        validates :display_set, presence: true, unless: Proc.new { |d| d.id == "hull:rootDisplaySet" }

        # Allows nil because the the test above will check for presence
        validates_exclusion_of :display_set_id, :in => lambda { |display_set| [display_set.id]}, :message => "cannot be a parent to itself", :allow_nil => true 
 
        # Overidden the Hydra::AccessControls::Permissions#permissions= method to enable setting of permissions on a
        # non rightsMetadata ds
        # See Hyhull::Models::StructuralSet::Permissions for implementation of set_permissions
        def permissions=(params)
          self.set_permissions(params, "rightsMetadata")
        end

        # Overidden the Hydra::AccessControls::Permissions#permissions method to enable get of permissions on a
        # non rightsMetadata ds
        # See Hyhull::Models::StructuralSet::Permissions for implementation of get_permissions
        def permissions
          self.get_permissions "rightsMetadata"
        end

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

        # All stuctural_sets at present get their rightsMetadata from hull-apo:structuralSet
        def set_rights_metadata
          admin_policy_obj = self.class.find("hull-apo:displaySet")
          raise "Unable to find hull-apo:displaySet" unless admin_policy_obj
          self.apo = admin_policy_obj
          apply_rights_metadata_from_apo
        end

        def apply_genre
          self.genre = "Display set"
        end

      end

      module ClassMethods
        # tree functionality is serviced by Hyhull::Models::SetTreeBehaviour 
        def tree
          tree_root = build_tree("hull:rootDisplaySet", "info\\:fedora\\/hull-cModel\\:displaySet")
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
