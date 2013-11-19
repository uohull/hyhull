module Hyhull::ResourceWorkflowBehaviour
  extend ActiveSupport::Concern
  include Hyhull::Validators  

  included do

    logger.info("Adding Hyhull::ResourceWorkflowBehaviour to the Hydra model")

    # Queue set 
    belongs_to :queue, property: :is_member_of, class_name: "QueueSet"
    belongs_to :queue_apo, property: :is_governed_by, :class_name => "QueueSet"
    
    # Note StructuralSet and APO are usually the same thing in hyhull... 
    # StructuralSet Parent
    belongs_to :parent, property: :is_member_of, :class_name => "StructuralSet"
    #APO Statement
    belongs_to :parent_apo, property: :is_governed_by, :class_name => "StructuralSet"


    # Local instance attribute for resource_state and apply_permissions_on_save
    attr_accessor :resource_state

    # get/set the resource_state on object after_initialize/before_save - This is needed to make state_machine work with AF
    after_initialize :get_resource_state
    before_update :set_apo
    before_save :resource_before_save_actions


    # Important the properties datastream must exist - this stores the resource_state
    delegate :_resource_state, to: "properties", :unique=>"true"

    # Standard resource_state workflow
    state_machine :resource_state, :initial => :proto, :namespace => 'resource'  do

      # Validate that the parent set is set within these states...
      state :published do
        validates :parent, presence: true
      end

      event :submit, human_name: "Submit the resource to QA" do
        transition [:proto, :hidden, :deleted  ] => :qa
      end
   
      event :publish, human_name: "Publish the resource" do
        transition :qa => :published 
      end
   
      event :hide, human_name: "Hide the resource"  do
        transition [:published, :qa] => :hidden
      end
  
      event :delete, human_name: "Delete the resource" do
        transition [:published, :hidden] => :deleted
      end

      after_transition any => [:qa, :published, :hidden, :deleted] do |resource, transition|
        # Set the Resource
        if transition.to_name == :published
          resource.queue = nil
          resource.apo = resource.parent
        else
          resource.queue_id = HYHULL_QUEUES.invert[transition.to_name]
          resource.apo = resource.queue
        end

        resource.apply_permissions = true  
      end

      after_transition any => [:hidden, :deleted] do |resource, transition|
        # After a transition from any states to hidden and deleted, do the following...
        resource.set_deleted_inner_state if resource.respond_to? :set_deleted_inner_state
      end

      after_transition [:hidden, :deleted] => [:qa] do |resource, transition|
        # After a transition from hidden and deleted to QA do the following...
        resource.set_active_inner_state if resource.respond_to? :set_active_inner_state   
      end

    end 
  end

  # Retrieves the apo based upon the current state...
  def apo 
    if self.queue_apo
      return self.queue_apo
    else
      return self.parent_apo
    end
  end
  
  # Sets the APO based upon the current resource_state
  def apo=(apo)
    self.queue_apo = nil
    self.parent_apo = nil

    if apo.instance_of? StructuralSet
      self.parent_apo = apo
    else
      self.queue_apo = apo
    end

  end

  # Invoked by the before_save callback this ensures that the 
  # correct apo is set for published resources.
  # Sets the apo to the parent object and and sets apply_permissions to true
  def set_apo
    if self.resource_published?
      # If the apo is already the parent the rights do not need updating..
      unless self.apo == self.parent
        raise "Parent not defined" if parent.nil?
        self.apo = self.parent
        self.apply_permissions = true  
      end
    end  
  end

  # As part of saving a resource, the following callbacks should be completed...
  def resource_before_save_actions
    # set_resource_state - This updates _resource_state property of resource for persistence 
    set_resource_state 
    
    # apply_rights_metadata_from_apo (hyhull:ModelMethods) - This method ensures that the resource rights reflect its APO
    apply_rights_metadata_from_apo

    # Full text indexing...
    # When self is published... 
    if self.resource_published? && self.class.ancestors.include?(Hyhull::FullTextIndexableBehaviour)
      # We re-extract the Full text if required.. 
      full_text_added = self.generate_full_text_datastream if self.require_text_extraction? 
      logger.warn "Resource workflow: Failed to extract the text from the content datastream of #{self.id}" unless full_text_added 
    end

  end  
 
  # Retrieve the resource_state from delegated _resource_state
  def get_resource_state
    begin   
      if self._resource_state.nil? || self._resource_state.empty?
        # Lets check wehther the resource exists within a queue...
        if self.queue
          # its in a queue so lets set the state based upon that... 
          self.resource_state = HYHULL_QUEUES[self.queue_id].to_s
        else  
          self.resource_state = "proto"
          set = QueueSet.find( HYHULL_QUEUES.invert[:proto])
          self.queue = set  
        end
      else
         self.resource_state = self._resource_state
      end
    rescue NameError, NoMethodError
      raise  StandardError.new("_resource_state cannot be bound correctly, does the properties datastream exists?  Include module Hyhull::ModelMethods to add datastream definition")
    end
  end

  # Set the delegated _resource_state from instance resource_state
  def set_resource_state
    self._resource_state = self.resource_state
  end

  # apply_permissions attribute - enables the Save callback apply_rights_metadata_from_apo to determine whether the  permissions needs refreshing from apo
  # Defaults to false. Set to true to force an update of the permissions. 
  def apply_permissions
    @apply_permissions || false
  end

  def apply_permissions=(val)
    @apply_permissions = val
  end

end