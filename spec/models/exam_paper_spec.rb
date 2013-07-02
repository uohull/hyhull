# encoding: utf-8
# spec/models/exam_paper_spec.rb
require 'spec_helper'

describe ExamPaper do
  
  context "original spec" do
    before(:each) do
      # Create a new etd object for the tests... 
      @exam_paper = ExamPaper.new

      @attributes_hash = {
        "title" => "44200 Accounting and Finance (2005/6)",
        "department_name" => "Business School",
        "subject_topic" => ["Accounting", "Finance"],
        "module_name" => ["Accounting and Finance"],
        "module_code" => ["44200"],
        "module_display" => ["44200 Accounting and Finance"],
        "exam_level" => "Level 4",
        "date_issued" => "2005/06",
        "rights" => "©2006 The University of Hull",
        "publisher" => "The University of Hull",
        "language_text" => "English",
        "language_code" => "eng",
        "resource_status" => "New nice object"
      }

      @invalid_attributes_hash = {
        "title" => "",
        "department_name" => "",
        "module_name" => [""],
        "module_code" => [""],
        "module_display" => [""],
        "subject_topic" => [""],
        "publisher" => "",
        "date_issued" => "January"
      }

    end

    it "should have the specified datastreams" do
      #Check for descMetadata datastream
      @exam_paper.datastreams.keys.should include("descMetadata")
      @exam_paper.descMetadata.should be_kind_of Datastream::ModsExamPaper
      @exam_paper.descMetadata.label.should == "MODS metadata"

      #Check for contentMetadata datastream
      @exam_paper.datastreams.keys.should include("contentMetadata")
      @exam_paper.contentMetadata.should be_kind_of Hyhull::Datastream::ContentMetadata

      #Check for the rightsMetadata datastream
      @exam_paper.datastreams.keys.should include("rightsMetadata")
      @exam_paper.rightsMetadata.should be_kind_of Hydra::Datastream::RightsMetadata
      @exam_paper.rightsMetadata.label.should == "Rights metadata"

      #Check for the properties datastream
      @exam_paper.datastreams.keys.should include("properties")
      @exam_paper.properties.should be_kind_of Hyhull::Datastream::WorkflowProperties
    end


    it "should have the attributes of an exam_paper object and support update_attributes" do
      @exam_paper.update_attributes( @attributes_hash )

      # Marked as 'unique' in the call to delegate... 
      @exam_paper.title.should == @attributes_hash["title"]
      @exam_paper.department_name.should == @attributes_hash["department_name"]
      @exam_paper.exam_level.should == @attributes_hash["exam_level"]
      @exam_paper.date_issued.should == @attributes_hash["date_issued"]
      @exam_paper.rights.should == @attributes_hash["rights"]
      @exam_paper.language_text == @attributes_hash["language_text"]
      @exam_paper.language_code == @attributes_hash["language_code"]
      @exam_paper.publisher == @attributes_hash["publisher"]
      @exam_paper.resource_status.should == @attributes_hash["resource_status"]

      # These attributes are not marked as 'unique' in the call to delegate, results will be arrays...
      @exam_paper.subject_topic.should == @attributes_hash["subject_topic"]  
      @exam_paper.module_name.should == @attributes_hash["module_name"]
      @exam_paper.module_code.should == @attributes_hash["module_code"]
      @exam_paper.module_display.should == @attributes_hash["module_display"]
    end

    it "should not save and respond with the correct number of validation errors " do
      @exam_paper.update_attributes( @invalid_attributes_hash )
      # save should be false
      @exam_paper.save.should be_false
      # with 8 error messages
      @exam_paper.errors.messages.size.should == 8
    end

    it "should display the correct messages for an invalid save attempt" do
      @exam_paper.update_attributes( @invalid_attributes_hash )
      # save should be false
      @exam_paper.save.should be_false
      # errors...
      @exam_paper.errors.messages[:title].should == ["can't be blank"]
      @exam_paper.errors.messages[:department_name].should == ["can't be blank"]
      @exam_paper.errors.messages[:module_name].should == ["is too short (minimum is 5 characters)"]
      @exam_paper.errors.messages[:module_code].should == ["is too short (minimum is 5 characters)"]
      @exam_paper.errors.messages[:module_display].should == ["is too short (minimum is 5 characters)"]
      @exam_paper.errors.messages[:subject_topic].should == ["is too short (minimum is 2 characters)"]
      @exam_paper.errors.messages[:publisher].should == ["can't be blank"]
      @exam_paper.errors.messages[:date_issued].should == ["is invalid"]
    end

    context "non unique fields" do
      before(:each) do
         @attributes_hash = {
           "subject_topic" => ["Finance", "Management"],
           "module_name" => ["Finance module", "Management module"],
           "module_code" => ["12345", "54321"],
           "module_display" => ["12345 - Finance module", "54321 Management module"]
         }
         @exam_paper = ExamPaper.new
         @exam_paper.update_attributes(@attributes_hash)
      end

      it "should not overwrite the subject_topic if it is not within the hash" do
        new_attributes_hash = { "title" => "Test title" }
        @exam_paper.update_attributes(new_attributes_hash)
        @exam_paper.title.should == new_attributes_hash["title"]
        @exam_paper.subject_topic.should == @attributes_hash["subject_topic"]
      end
    end

  #   context "non unique fields" do
  #     before(:each) do
  #       @attributes_hash = {
  #         "title" => "A thesis describing the...",
  #         "person_name" => ["Smith, John.", "Supervisor, A."],
  #         "person_role_text" => ["Creator", "Supervisor"],
  #         "organisation_name" => ["The University of Hull"],
  #         "organisation_role_text" =>["Funder"],
  #         "abstract" => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
  #         "subject_topic" => ["Subject of the matter"],
  #         "grant_number" => ["GN:122335"] 
  #       } 
  #       @etd.update_attributes( @attributes_hash )        
  #     end
  #     it "should not overwrite the person_name and person_role_text if they are not within the attributes" do
  #       new_attributes_hash = { "title" => "A new title" }
  #       @etd.update_attributes( new_attributes_hash )
  #       @etd.title.should == new_attributes_hash["title"]
  #       @etd.person_name.should ==  @attributes_hash["person_name"]
  #       @etd.person_role_text.should == @attributes_hash["person_role_text"]
  #     end

  #     it "should not overwrite the subject_topic if they are not within the attributes" do
  #       new_attributes_hash = { "title" => "A new title part 2" }
  #       @etd.update_attributes( new_attributes_hash )
  #       @etd.title.should == new_attributes_hash["title"]
  #       @etd.subject_topic.should == @attributes_hash["subject_topic"]
  #     end   

  #     it "should not overwrite the grant_number if they are not within the attributes" do
  #       new_attributes_hash = { "title" => "A new title part 3" }
  #       @etd.update_attributes( new_attributes_hash )
  #       @etd.title.should == new_attributes_hash["title"]
  #       @etd.grant_number.should == @attributes_hash["grant_number"]
  #     end
  #   end

  # end

  # context "methods" do
  #     before(:each) do
  #         #set the 'required' fields
  #         @valid_etd  =  UketdObject.new
  #         @valid_etd.title = "Test title"
  #         @valid_etd.person_name = ["Smith, John.", "Jones, John"]
  #         @valid_etd.person_role_text = ["Creator", "Creator"]
  #         @valid_etd.subject_topic = ["Topci 1"]
  #         @valid_etd.language_code = "eng"
  #         @valid_etd.language_text = "English"
  #         @valid_etd.publisher = "IT, UoH"
  #         @valid_etd.qualification_name = "Undergraduate"
  #         @valid_etd.qualification_level = "BSc"
  #         @valid_etd.date_issued = "2012"
  #         @valid_etd.save
  #     end
  #     after(:all) do
  #       @valid_etd.delete
  #     end
  #     describe ".to_solr" do
  #       it "should return the necessary facets" do
  #         solr_doc = @valid_etd.to_solr
  #         solr_doc["object_type_sim"].should == "Thesis or dissertation"
  #       end

  #       it "should return the necessary cModels" do
  #         solr_doc = @valid_etd.to_solr
  #         solr_doc["has_model_ssim"].should == ["info:fedora/hydra-cModel:commonMetadata", "info:fedora/hydra-cModel:genericParent", "info:fedora/hull-cModel:uketdObject"]
  #       end
  #     end
  #     describe ".save" do
  #       it "should create the appropriate cModel declarations" do       
  #         @valid_etd.ids_for_outbound(:has_model).should == ["hydra-cModel:commonMetadata", "hydra-cModel:genericParent", "hull-cModel:uketdObject"] 
  #       end
  #       it "should contain the appropiately case for the uketdObject in the RELS-EXT (Lower Camelcase)" do
  #         @valid_etd.rels_ext.to_rels_ext.include?('info:fedora/hull-cModel:uketdObject').should == true
  #       end
  #       it "apply_additional_metadata should pre-populate the copyright (rights) field" do
  #         @valid_etd.rights.should == "© 2012 John Smith and John Jones. All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holders." 
  #       end
  #     end
     
  # end

  # context "resource_state" do
  #   before(:each) do
  #     #set the general 'required' fields for an object
  #     @valid_etd  =  UketdObject.new
  #     @valid_etd.title = "Test title"
  #     @valid_etd.person_name = ["Smith, John."]
  #     @valid_etd.person_role_text = ["Creator"]
  #     @valid_etd.subject_topic = ["Topci 1"]
  #     @valid_etd.language_code = "eng"
  #     @valid_etd.language_text = "English"
  #     @valid_etd.publisher = "IT, UoH"
  #     @valid_etd.qualification_name = "Undergraduate"
  #     @valid_etd.qualification_level = "BSc"
  #     @valid_etd.date_issued = "2012"
  #     @valid_etd.save
  #   end

  #   after(:all) do
  #     @valid_etd.delete
  #   end

  #   describe "hidden" do
  #     it "should validate that the required field 'resource status' is populated" do

  #       #Submit the resource so that it can be hidden... 
  #       @valid_etd.submit_resource
  #       #Save the state... 
  #       @valid_etd.save
        
  #       @valid_etd.resource_state.should == "qa"

  #       #Hide the resource...
  #       @valid_etd.hide_resource.should be_true
        
  #       #Save should fail because of the validation state callback
  #       @valid_etd.save.should be_false
  #       @valid_etd.errors.messages[:resource_status].should == ["can't be blank"]
        
  #       #Populate thteh required field
  #       @valid_etd.resource_status = "Hidden due to Copyright enquiry"
  #       #Save should work...
  #       @valid_etd.save.should be_true
  #     end
  #   end

  #   describe "deleted" do
  #     it "should validate that the required field 'resource status' is populated" do
  #       #Submit the resource so that it can be hidden... 
  #       @valid_etd.submit_resource
  #       @valid_etd.publish_resource
  #       #Save the state... 
  #       @valid_etd.save

  #       @valid_etd.resource_state.should == "published"

  #       #'Delete' the resource...
  #       @valid_etd.delete_resource.should be_true
        
  #       #Save should fail because of the validation state callback
  #       @valid_etd.save.should be_false
  #       @valid_etd.errors.messages[:resource_status].should == ["can't be blank"]

  #       #Populate thteh required field
  #       @valid_etd.resource_status = "Deleted due to duplicate record"
  #       #Save should work...
  #       @valid_etd.save.should be_true
  #     end
  #   end

  end

end

