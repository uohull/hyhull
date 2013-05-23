module Hyhull::ResourceWorkflowBehaviour
  extend ActiveSupport::Concern
  include Hyhull::Validators  

  included do

    logger.info("Adding Hyhull::ResourceWorkflowBehaviour to the Hydra model")

    # Local instance attribute for resource_state
    attr_accessor :resource_state

    # get/set the resource_state on object after_initialize/before_save - This is needed to make state_machine work with AF
    after_initialize :get_resource_state
    before_save :set_resource_state

    # Important the properties datastream must exist - this stores the resource_state
    delegate :_resource_state, to: "properties", :unique=>"true" 

    # Standard resource_state workflow
    state_machine :resource_state, :initial => :proto, :namespace => 'resource'  do
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
    end 
  end

  # Retrieve the resource_state from delegated _resource_state
  def get_resource_state
    begin   
      if self._resource_state.nil? || self._resource_state.empty? 
        self.resource_state = "proto"
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

end