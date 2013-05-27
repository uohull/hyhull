# lib/hyhull/models/structural_set.rb
# Object model for the hyhull structural_set
module Hyhull
  module Models
    module StructuralSet
      extend ActiveSupport::Concern
      included do 
        include Hyhull::ModelMethods

        has_metadata name: "descMetadata", label: "MODS metadata", type: Hyhull::Datastream::ModsStructuralSet
        has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata
        has_metadata name: "defaultObjectRights", label: "Default object rights", type: Hyhull::Datastream::DefaultObjectRights

        delegate_to :descMetadata, [:title, :description, :resource_status], unique: true

        has_many :children, property: :is_member_of, :class_name => "ActiveFedora::Base"
        belongs_to :parent, property: :is_member_of        
      end

      # assert_content_model overidden to add UketdObject custom models
      def assert_content_model
        add_relationship(:has_model, "info:fedora/hydra-cModel:commonMetadata")
        super
      end

    end 
  end
end