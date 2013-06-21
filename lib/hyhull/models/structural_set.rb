# lib/hyhull/models/structural_set.rb
# Object model for the hyhull structural_set
module Hyhull
  module Models
    module StructuralSet
      extend ActiveSupport::Concern
      
      included do      
        include Hyhull::ModelMethods
        include Hyhull::Models::StructuralSet::Permissions
        include Hyhull::Models::StructuralSetAncestryBehaviour
        include Hydra::ModelMixins::RightsMetadata

        has_metadata name: "descMetadata", label: "MODS metadata", type: Hyhull::Datastream::ModsStructuralSet

        delegate_to :descMetadata, [:title, :description, :resource_status, :genre, :type_of_resource], unique: true
        
        belongs_to :parent, property: :is_member_of, :class_name => "StructuralSet"
        belongs_to :apo, property: :is_governed_by, :class_name => "StructuralSet"

        has_many :children, property: :is_member_of, :class_name => "ActiveFedora::Base"
        has_many :apo_children, property: :is_governed_by, :class_name => "ActiveFedora::Base"

        validates :title, presence: true
        validates :parent, presence: true
        validates_exclusion_of :parent_id, :in => lambda { |p| [p.id]}, :message => "cannot be a parent to itself"
      end

      # assert_content_model overidden to add UketdObject custom models
      def assert_content_model
        add_relationship(:has_model, "info:fedora/hydra-cModel:commonMetadata")
        super
      end  

    end 
  end
end