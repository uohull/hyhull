module Hyhull::OaiHarvestableBehaviour 
  extend ActiveSupport::Concern

  included do
    logger.info("Adding Hyhull::OaiHarvestableBehaviour to the Hydra model")
   
    # Harvestable resources must be asssigned to a Harvesting Set
    belongs_to :harvesting_set, property: :is_member_of_collection, :class_name => "HarvestingSet"

    self.state_machine :resource_state do   
      # Validate that the harvesting set is set...
      state :published do
        validates :harvesting_set, presence: true
      end

      after_transition any => [:hidden, :deleted] do |resource, transition|
        # After a transition from any states to hidden and deleted, do the following...
        # resource.set_deleted_inner_state if resource.respond_to? :set_deleted_inner_state
        logger.info("Hyhull::OaiHarvestableBehaviour: Resource transitioning to #{transition.to}. Removing oai_item_id from rels-ext.")
        resource.remove_oai_item_id
      end

      after_transition any => :published do |resource, transition|
        # After a transition from hidden and deleted to QA do the following...
        # resource.set_active_inner_state if resource.respond_to? :set_active_inner_state 
        logger.info("Hyhull::OaiHarvestableBehaviour: Resource transitioning to #{transition.to}. Adding oai_item_id to rels-ext.")
        resource.add_oai_item_id
      end
    end

  end

  # Adding an oai_item_id needs adding to a resource for it to be picked up the OAI_Provider tool
  def add_oai_item_id
    #literal specifies that it should be in the form of...<oai:itemID>...</oai:itemID>
    self.add_relationship :oai_item_id, OAI_ITEM_IDENTIFIER_NS + self.pid, :literal => true
  end
 
  # Removing the oai_item_id from a resource will ensure that resource is not included on the harvest list
  def remove_oai_item_id
    #literal specifies that it should be in the form of...<oai:itemID>...</oai:itemID>
    self.remove_relationship :oai_item_id, OAI_ITEM_IDENTIFIER_NS + self.pid, :literal => true
  end

end  