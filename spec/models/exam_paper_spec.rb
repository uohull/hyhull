# encoding: utf-8
# spec/models/exam_paper_spec.rb
require 'spec_helper'

describe ExamPaper do
  
  context "original spec" do
    before(:each) do
      # Create a new etd object for the tests... 
      @exam_paper = ExamPaper.new

      @attributes_hash = {
        "title" => "44200 Accounting and Finance (May 2005)",
        "department_name" => "Business School",
        "subject_topic" => ["Accounting", "Finance"],
        "module_name" => ["Accounting and Finance"],
        "module_code" => ["44200"],
        "module_display" => ["44200 Accounting and Finance"],
        "exam_level" => "Level 4",
        "date_issued" => "2005-05",
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

    it "should include Full text Indexable behaviour" do
      @exam_paper.class.ancestors.should include(Hyhull::FullTextIndexableBehaviour)
    end

    it "genre should be set to 'Examination paper'" do
      @exam_paper.genre.should == "Examination paper"
    end

    it "should have the attributes of an exam_paper object and support update_attributes" do
      @exam_paper.update_attributes( @attributes_hash )

      # Marked as 'unique' in the call to delegate... 
      @exam_paper.department_name.should == @attributes_hash["department_name"]
      @exam_paper.exam_level.should == @attributes_hash["exam_level"]
      @exam_paper.date_issued.should == @attributes_hash["date_issued"]
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


    it "should behave as expected when updating module attributes" do
      module_names = ["New module"]
      module_codes = ["12345"]
      module_display = ["12345 New module"]

      @exam_paper.module_name = module_names
      @exam_paper.module_code = module_codes
      @exam_paper.module_display = module_display

      @exam_paper.module_name.should == module_names
      @exam_paper.module_code.should == module_codes
      @exam_paper.module_display.should == module_display

      new_module_names = ["Another one", "Another two",  "Another three"]
      new_module_codes = ["11111", "22222", "33333"]
      new_module_display = ["11111 Another one", "22222 Another two", "33333 Another three"]

      @exam_paper.module_name = new_module_names
      @exam_paper.module_code = new_module_codes
      @exam_paper.module_display = new_module_display

      @exam_paper.module_name.should == new_module_names
      @exam_paper.module_code.should == new_module_codes
      @exam_paper.module_display.should == new_module_display

    end

    it "should not save and respond with the correct number of validation errors " do
      @exam_paper.update_attributes( @invalid_attributes_hash )
      # save should be false
      @exam_paper.save.should be_false
      # with 8 error messages
      @exam_paper.errors.messages.size.should == 6
    end

    it "should display the correct messages for an invalid save attempt" do
      @exam_paper.update_attributes( @invalid_attributes_hash )
      # save should be false
      @exam_paper.save.should be_false
      # errors...
      #@exam_paper.errors.messages[:title].should == ["can't be blank"]
      @exam_paper.errors.messages[:department_name].should == ["can't be blank"]
      @exam_paper.errors.messages[:module_name].should == ["is too short (minimum is 3 characters)"]
      @exam_paper.errors.messages[:module_code].should == ["is too short (minimum is 5 characters)"]
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

   context "methods" do
      before(:each) do
        #set the 'required' fields
        @valid_exam_paper  =  ExamPaper.new
        @valid_exam_paper.department_name = "Business school"
        @valid_exam_paper.date_issued = "2012-05"
        @valid_exam_paper.publisher = "University of Hull"
        @valid_exam_paper.module_name = ["Accounting and Finance", "Financing and Accounting"]
        @valid_exam_paper.module_code = ["12345", "54321"]
        @valid_exam_paper.subject_topic = ["Finance", "Accounting"]
        @valid_exam_paper.language_code = "eng"
        @valid_exam_paper.language_text = "English"
        @valid_exam_paper.save
      end
      after(:each) do
        @valid_exam_paper.delete
      end
      describe ".to_solr" do
        it "should return the necessary facets" do
          solr_doc = @valid_exam_paper.to_solr
          solr_doc["object_type_sim"].should == "Examination paper"
        end

        it "should return the necessary cModels" do
          solr_doc = @valid_exam_paper.to_solr
          solr_doc["has_model_ssim"].should == ["info:fedora/hydra-cModel:compoundContent", "info:fedora/hydra-cModel:commonMetadata", "info:fedora/hull-cModel:examPaper"]
        end
      end
      describe ".save" do
        it "should create the appropriate cModel declarations" do       
          @valid_exam_paper.ids_for_outbound(:has_model).should == ["hydra-cModel:compoundContent", "hydra-cModel:commonMetadata", "hull-cModel:examPaper"] 
        end
        it "should contain the appropiately case for the uketdObject in the RELS-EXT (Lower Camelcase)" do
          @valid_exam_paper.rels_ext.to_rels_ext.include?('info:fedora/hull-cModel:examPaper').should == true
        end
        it "apply_additional_metadata should pre-populate the copyright (rights) field" do
          @valid_exam_paper.rights.should == "© 2012 University of Hull. All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holder." 
        end
        it "apply_additional_metadata should pre-populate the module_display array with the appropiate text" do
          @valid_exam_paper.module_display.should == ["12345 Accounting and Finance", "54321 Financing and Accounting"]
        end
        it "apply_additional_metadata should pre-populate the title with the appropiate text" do
          @valid_exam_paper.title.should == "12345 Accounting and Finance & 54321 Financing and Accounting (May 2012)"
        end

      end
     
  end

  context "resource_state" do
      before(:each) do
        #set the 'required' fields
        @a_valid_exam_paper  =  ExamPaper.new
        @a_valid_exam_paper.department_name = "Business school"
        @a_valid_exam_paper.date_issued = "2012-05"
        @a_valid_exam_paper.publisher = "University of Hull"
        @a_valid_exam_paper.module_name = ["Accounting and Finance", "Financing and Accounting"]
        @a_valid_exam_paper.module_code = ["12345", "54321"]
        @a_valid_exam_paper.subject_topic = ["Finance", "Accounting"]
        @a_valid_exam_paper.language_code = "eng"
        @a_valid_exam_paper.language_text = "English"
        @a_valid_exam_paper.save
      end

      after(:each) do
        @a_valid_exam_paper.delete
      end

      describe "qa and published" do
        it "should validate that the field title is populated" do
          # Submit resource to qa...
          @a_valid_exam_paper.submit_resource
          @a_valid_exam_paper.save
  
          @a_valid_exam_paper.title = ""
          @a_valid_exam_paper.save.should be_false
          @a_valid_exam_paper.errors.messages[:title].should == ["can't be blank"]

          # Add another title and save...
          @a_valid_exam_paper.title = "Test"
          @a_valid_exam_paper.save

          # Publish it and save...
          @a_valid_exam_paper.publish_resource
          @a_valid_exam_paper.save

          @a_valid_exam_paper.title = ""
          @a_valid_exam_paper.save.should be_false
          @a_valid_exam_paper.errors.messages[:title].should == ["can't be blank"]
        end
      end

      describe "hidden" do
        it "should validate that the required field 'resource status' is populated" do

          #Submit the resource so that it can be hidden... 
          @a_valid_exam_paper.submit_resource
          #Save the state... 
          @a_valid_exam_paper.save
          
          @a_valid_exam_paper.resource_state.should == "qa"

          #Hide the resource...
          @a_valid_exam_paper.hide_resource.should be_true
          
          #Save should fail because of the validation state callback
          @a_valid_exam_paper.save.should be_false
          @a_valid_exam_paper.errors.messages[:resource_status].should == ["can't be blank"]
          
          #Populate thteh required field
          @a_valid_exam_paper.resource_status = "Hidden due to Copyright enquiry"
          #Save should work...
          @a_valid_exam_paper.save.should be_true
        end
      end


      describe "deleted" do
        it "should validate that the required field 'resource status' is populated" do
          #Submit the resource so that it can be hidden... 
          @a_valid_exam_paper.submit_resource
          @a_valid_exam_paper.publish_resource
          #Save the state... 
          @a_valid_exam_paper.save

          @a_valid_exam_paper.resource_state.should == "published"

          #'Delete' the resource...
          @a_valid_exam_paper.delete_resource.should be_true
          
          #Save should fail because of the validation state callback
          @a_valid_exam_paper.save.should be_false
          @a_valid_exam_paper.errors.messages[:resource_status].should == ["can't be blank"]

          #Populate thteh required field
          @a_valid_exam_paper.resource_status = "Deleted due to duplicate record"
          #Save should work...
          @a_valid_exam_paper.save.should be_true
        end
      end

    end

  end

end

