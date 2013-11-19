# encoding: utf-8
# spec/models/harvesting_set_spec.rb
require 'spec_helper'


describe HarvestingSet do
  
  context "original spec" do
    before(:each) do
      # Create a new harvesting_set object for the tests... 
      @harvesting_set = HarvestingSet.new
    end

    it "should have the specified datastreams" do
      #Check for descMetadata datastream
      @harvesting_set.datastreams.keys.should include("descMetadata")
      @harvesting_set.descMetadata.should be_kind_of Hyhull::Datastream::ModsSet
      @harvesting_set.descMetadata.label.should == "MODS metadata"

      #Check for the rightsMetadata datastream
      @harvesting_set.datastreams.keys.should include("rightsMetadata")
      @harvesting_set.rightsMetadata.should be_kind_of Hydra::Datastream::RightsMetadata
      @harvesting_set.rightsMetadata.label.should == "Rights metadata"

      #Check for the properties datastream - Although at present Harvesting sets are not created within the Hydra application
      @harvesting_set.datastreams.keys.should include("properties")
      @harvesting_set.properties.should be_kind_of Hyhull::Datastream::WorkflowProperties
    end

    it "should return a tree" do
      root_node = HarvestingSet.tree
      root_node.print_tree

      # There should be more than one child///
      root_node.children.size.should == 1

      puts "Attempting to get options for select"
      options = root_node.options_for_nested_select

      options.each {|v| puts "#{v[0]} = #{v[1]}" }
    end

    it "should return json" do
      root_node = HarvestingSet.tree

      puts "Attempting to get json from tree"
      json = root_node.to_json

      json.include?("label").should be_true
      json.include?("id").should be_true

      json.include?("name").should be_false
      json.include?("content").should be_false
    end

    describe "a saved instance" do
      before do
        @instance = HarvestingSet.find("hull:ETD")
        @etd_biosciences = HarvestingSet.find("hull:ETDBiosciences")
      end

      describe ".children" do
        it "should return the child Harvesting Sets" do
          @instance.children.should include(HarvestingSet.find("hull:ETDAmericanStudies"), HarvestingSet.find("hull:ETDAdultEducation"), HarvestingSet.find("hull:ETDBiosciences"), HarvestingSet.find("hull:ETDAccounting"))
        end
      end

      describe ".parent" do
        it "should return the parent Harvesting Set" do
          @instance.parent.should == HarvestingSet.find("hull:rootHarvestingSet")
        end
      end

      describe ".harvestable_resources" do
        it "should return the test fixtire hull:756" do
          @etd_biosciences.harvestable_resources.should include(UketdObject.find("hull:756")) 
        end
      end

    end

  end

end