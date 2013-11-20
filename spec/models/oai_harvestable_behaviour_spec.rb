require 'spec_helper'

class HarvestingTestClass < ActiveFedora::Base
  include Hyhull::ModelMethods
  include Hyhull::ResourceWorkflowBehaviour
  include Hyhull::OaiHarvestableBehaviour
  has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata

  def initialize
    super
    # For testing purposes we set a root set
    self.parent_id = "hull:rootSet"
  end

end

describe Hyhull::OaiHarvestableBehaviour do 

  context "HarvestingTestClass" do
    before(:each) do
      @harvesting_test_class = HarvestingTestClass.new
      @harvesting_test_class.submit_resource!
      @harvesting_test_class.save       
    end

    after(:each) do
      @harvesting_test_class.delete
    end

    describe ".harvesting_set" do
      it "should be a property of the resource" do
        @harvesting_test_class.respond_to?(:harvesting_set).should be_true
      end

      describe "validation" do
        it "should return false when the resource is published without being set" do
          @harvesting_test_class.publish_resource!
          @harvesting_test_class.save.should be_false
          @harvesting_test_class.errors.messages.should == {:harvesting_set=>["not assigned"]}
        end

        it "should return true when the resource is published and is set" do
          @harvesting_test_class.harvesting_set = HarvestingSet.find("hull:ETDAccounting")
          @harvesting_test_class.publish_resource!
          @harvesting_test_class.save.should be_true
        end
      end
    end

    describe "oai_item_id" do
      it "should be added to the Resource RELS-EXT when it is moved to the published queue" do
        @harvesting_test_class.harvesting_set = HarvestingSet.find("hull:ETDAccounting")
        @harvesting_test_class.publish_resource!
        @harvesting_test_class.save!

        # Check the RELS-EXT for the OAI item id
        @harvesting_test_class.rels_ext.content.should include("<oai:itemID>#{OAI_ITEM_IDENTIFIER_NS}#{@harvesting_test_class.id}</oai:itemID>")
      end
    
      it "should be removed from the Resource RELS-EXT when it is moved to the hidden queue" do
        @harvesting_test_class.harvesting_set = HarvestingSet.find("hull:ETDAccounting")
        @harvesting_test_class.publish_resource!
        @harvesting_test_class.save!

        @harvesting_test_class.hide_resource!
        @harvesting_test_class.save!

        # Check the RELS-EXT does not include OAI item id
        @harvesting_test_class.rels_ext.content.should_not include("<oai:itemID>#{OAI_ITEM_IDENTIFIER_NS}#{@harvesting_test_class.id}</oai:itemID>")
      end

      it "should be removed from the Resource RELS-EXT when it is moved to the deleted queue" do
        @harvesting_test_class.harvesting_set = HarvestingSet.find("hull:ETDAccounting")
        @harvesting_test_class.publish_resource!
        @harvesting_test_class.save!

        @harvesting_test_class.delete_resource!
        @harvesting_test_class.save!

        # Check the RELS-EXT does not include OAI item id
        @harvesting_test_class.rels_ext.content.should_not include("<oai:itemID>#{OAI_ITEM_IDENTIFIER_NS}#{@harvesting_test_class.id}</oai:itemID>")
      end
    end
  end

end


