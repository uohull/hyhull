# encoding: utf-8
# spec/models/display_set_spec.rb
require 'spec_helper'


class DisplayChildObjectTestClass < ActiveFedora::Base
  include Hyhull::ModelMethods

  has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata

  belongs_to :parent, property: :is_member_of, :class_name => "StructuralSet"
  belongs_to :display_set, property: :is_member_of, :class_name => "DisplaySet"

  def title 
    "Test resource"
  end

  def date_valid
    "2010-01-01"
  end

  def genre
    "Test genre"
  end

  def resource_state
    "published"
  end

  def resource_published?
    true
  end

  def owner_id
    "fooAdmin"
  end

  def initialize
    super
  end

end

describe DisplaySet do
  
  context "original spec" do
    before(:each) do
      # Create a new display_set object for the tests... 
      @display_set = DisplaySet.new
    end

    it "should have the specified datastreams" do
      #Check for descMetadata datastream
      @display_set.datastreams.keys.should include("descMetadata")
      @display_set.descMetadata.should be_kind_of Hyhull::Datastream::ModsSet
      @display_set.descMetadata.label.should == "MODS metadata"

      #Check for the rightsMetadata datastream
      @display_set.datastreams.keys.should include("rightsMetadata")
      @display_set.rightsMetadata.should be_kind_of Hydra::Datastream::RightsMetadata
      @display_set.rightsMetadata.label.should == "Rights metadata"

      #Check for the properties datastream
      @display_set.datastreams.keys.should include("properties")
      @display_set.properties.should be_kind_of Hyhull::Datastream::WorkflowProperties

    end

    it "genre should be set to 'Display set'" do
      @display_set.genre.should == "Display set"
    end

    it "should have the attributes of an display set object and support update_attributes" do
      attributes_hash = {
        "title" => "Artwork",
        "description" => "University collection of Artwork",
        "resource_status" => "Currently empty",
        "type_of_resource" => "mixed material"
      } 

      @display_set.update_attributes( attributes_hash )
      @display_set.title.should == attributes_hash["title"]
      @display_set.description.should == attributes_hash["description"]
      @display_set.resource_status.should == attributes_hash["resource_status"]
      @display_set.type_of_resource.should == attributes_hash["type_of_resource"]
    end

    it "should have the required relationships" do
      @display_set.respond_to?(:display_set).should == true
      @display_set.respond_to?(:apo).should == true
      @display_set.respond_to?(:children).should == true
    end

    it "should return a tree" do
      root_node = DisplaySet.tree
      root_node.print_tree

      # There should be more than one child///
      root_node.children.size.should >= 1

      puts "Attempting to get options for select"
      options = root_node.options_for_nested_select

      options.each {|v| puts "#{v[0]} = #{v[1]}" }
    end

    it "should return json" do
      root_node = DisplaySet.tree

      puts "Attempting to get json from tree"
      json = root_node.to_json

      json.include?("label").should be_true
      json.include?("id").should be_true

      json.include?("name").should be_false
      json.include?("content").should be_false
    end

    it "should enforce validation on title and display_set" do
      @display_set.save.should == false
      @display_set.errors.messages.should == {:title=>["can't be blank"], :display_set=>["can't be blank"]} 
    end

    it "should do provide a set of options for a fedora_select nested select" do
      options = DisplaySet.tree.options_for_nested_select
      options.each {|v| puts "#{v[0]} = #{v[1]}" }
    end

    describe "a saved instance" do
      before do
        @instance = DisplaySet.new
        @instance.title = "Test set"
        @instance.display_set_id = "hull:rootDisplaySet"        
        @instance.save
        @instance = DisplaySet.find(@instance.id)
      end

      it "should be governedBy " do
        @instance.apo.id.should == "hull-apo:displaySet"
      end
      
      it "should inherit the rightsMetadata form hull-apo:displaySet" do
        @instance.rightsMetadata.content.should be_equivalent_to DisplaySet.find("hull-apo:displaySet").rightsMetadata.content
      end

      it "apply_depositor_metadata should not update the rightsMetadata" do
        @instance.apply_depositor_metadata("Me", "me@example.com")
        @instance.depositor.should == "Me"
        @instance.depositor_email.should == "me@example.com"
        # Unlile in the Hyhull::Models variant apply_depositor_metadata should not set the rightsMetadata to the edit by the individual 
        @instance.rightsMetadata.individuals.should == {}   
      end

      after do
        @instance.delete
      end
    end  
  end

end
