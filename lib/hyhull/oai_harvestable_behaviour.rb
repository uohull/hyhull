module Hyhull::OaiHarvestableBehaviour 
  extend ActiveSupport::Concern

  included do
    logger.info("Adding Hyhull::OaiHarvestableBehaviour to the Hydra model")

    # Synchronise the OAI Item ID when the resource is published (Safety check)
    # Using after_validation to ensure that the callback is run before any update rels_ext save processes
    after_validation :synchronise_oai_item_id, if: :resource_published? 
   
    # Harvestable resources must be asssigned to a Harvesting Set
    belongs_to :harvesting_set, property: :is_member_of_collection, :class_name => "HarvestingSet"

    self.state_machine :resource_state do   
      # Validate that the harvesting set is set...
      # Sample validation... Not using as standard
      # state :published do
      #  validates :harvesting_set, presence: { message: "not assigned" }
      # end

      after_transition any => [:hidden, :deleted] do |resource, transition|
        # Only when a harvesting_set is set...
        unless resource.harvesting_set.nil? 
          # After a transition from any states to hidden and deleted, do the following...
          # resource.set_deleted_inner_state if resource.respond_to? :set_deleted_inner_state
          logger.info("Hyhull::OaiHarvestableBehaviour: Resource transitioning to #{transition.to}. Removing oai_item_id from rels-ext.")
          resource.remove_oai_item_id
        end
      end

      after_transition any => :published do |resource, transition|
        # Only when a harvesting_set is set...
        unless resource.harvesting_set.nil? 
          # After a transition from hidden and deleted to QA do the following...
          # resource.set_active_inner_state if resource.respond_to? :set_active_inner_state 
          logger.info("Hyhull::OaiHarvestableBehaviour: Resource transitioning to #{transition.to}. Adding oai_item_id to rels-ext.")
          resource.add_oai_item_id
        end
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

  # Synchronises the addition/removal of the oai_item_id predicate within RELS-EXT based upon the setting of a harvesting_set
  # I.e. In a published state, if the resource is removed from a harvesting set, we also want to remove the oai_item_id
  def synchronise_oai_item_id
    # When the harvesting set is nil and an oai_item_id relationship exists... We remove it (not needed) 
    if self.harvesting_set.nil? && !self.relationships(:oai_item_id).empty?
      self.remove_oai_item_id
    # When a harvesting set is set, and oai_item_id relationship doesn't exist... We need to add it
    elsif !self.harvesting_set.nil? && self.relationships(:oai_item_id).empty? 
      self.add_oai_item_id
    end
  end

end  