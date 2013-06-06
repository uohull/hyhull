# lib/hyhull/models/structural_set.rb
# Object model for the hyhull structural_set
module Hyhull
  module Models
    module StructuralSet
      extend ActiveSupport::Concern
      
      included do      
        include Hyhull::ModelMethods
        include Hyhull::Models::StructuralSetAncestryBehaviour  

        before_create :set_rightsMetadata, :apply_defaultObjectRights

        has_metadata name: "descMetadata", label: "MODS metadata", type: Hyhull::Datastream::ModsStructuralSet
        has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata
        has_metadata name: "defaultObjectRights", label: "Default object rights", type: Hyhull::Datastream::DefaultObjectRights

        delegate_to :descMetadata, [:title, :description, :resource_status], unique: true

        belongs_to :parent, property: :is_member_of, :class_name => "StructuralSet"
        has_many :children, property: :is_member_of, :class_name => "ActiveFedora::Base"

        validates :title, presence: true
        validates :parent, presence: true

      end

      # assert_content_model overidden to add UketdObject custom models
      def assert_content_model
        add_relationship(:has_model, "info:fedora/hydra-cModel:commonMetadata")
        super
      end

      # All stuctural_sets at present get their rightsMetadata from hull-apo:structuralSet
      def set_rightsMetadata
        apo = ActiveFedora::Base.find("hull-apo:structuralSet")
        raise "Unable to find hull-apo:structuralSet" unless apo
        add_relationship :is_governed_by, apo
        apply_rights_metadata_from_apo(apo)
      end

      # Method for updating the permissions on the set. If the permissions are changing on the defaultObjectRights, ancestors will need updating...
      # @permission_params permission_params ex “group”=>{“group1”=>“discover”,“group2”=>“edit”, “person”=>“person1”=>“read”,“person2”=>“discover”}
      # @ds_id ds_id specify the rights datastream (usually rightsMetadata or defaultObjectRights)
      def update_permissions(permission_params, ds_id)
        #If changing defaultObjectRights we need to change the children...
        if ds_id == "defaultObjectRights"
          update_ancestors_permissions permission_params
        end
        #update the parents
        update_resource_permissions(permission_params, ds_id)
      end

      # Inherit the defaultObjectRights from the set's parent. 
      def apply_defaultObjectRights
        raise "Unable to find parent. Cannot apply defaultObjectRights" unless parent
        defaultRights = Hyhull::Datastream::DefaultObjectRights.new(self.inner_object, 'defaultObjectRights')
        Hydra::Datastream::RightsMetadata.from_xml(parent.defaultObjectRights.content, defaultRights)
        datastreams["defaultObjectRights"] = defaultRights if self.datastreams.has_key? "defaultObjectRights" 
      end

    end 
  end
end