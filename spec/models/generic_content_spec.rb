# encoding: utf-8
# spec/models/generic_content_spec.rb
require 'spec_helper'

describe GenericContent do
  
  context "original spec" do
    before(:each) do
      # Create a new Generic Content object for the tests... 
      @generic_content = GenericContent.new
    end

    it "should have the specified datastreams" do
      #Check for descMetadata datastream
      @generic_content.datastreams.keys.should include("descMetadata")
      @generic_content.descMetadata.should be_kind_of Datastream::ModsGenericContent
      @generic_content.descMetadata.label.should == "MODS metadata"

      #Check for contentMetadata datastream
      @generic_content.datastreams.keys.should include("contentMetadata")
      @generic_content.contentMetadata.should be_kind_of Hyhull::Datastream::ContentMetadata

      #Check for the rightsMetadata datastream
      @generic_content.datastreams.keys.should include("rightsMetadata")
      @generic_content.rightsMetadata.should be_kind_of Hydra::Datastream::RightsMetadata
      @generic_content.rightsMetadata.label.should == "Rights metadata"

      #Check for the properties datastream
      @generic_content.datastreams.keys.should include("properties")
      @generic_content.properties.should be_kind_of Hyhull::Datastream::WorkflowProperties
    end

    it "should have the attributes of an Generic Content and support update_attributes" do
      attributes_hash = {
        "title" => "A thesis describing the...",
        "person_name" => ["Smith, John.", "Supervisor, A."],
        "person_role_text" => ["Author", "Supervisor"],
        "description" => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        "subject_topic" => ["Subject of the matter"], 
        "subject_geographic" => "Hull",
        "subject_temporal" => "2013",
        "location_coordinates" => "12, 10",
        "location_label" => "The location label",
        "location_coordinates_type" => "Point",
        "genre" => "Presentation",
        "type_of_resource" => "Text",
        "date_valid" => "1983-03-01",
        "language_text" => "English",
        "language_code" => "eng",
        "publisher" => "ICTD, The University of Hull",
        "resource_status" => "New nice object",        
        "related_web_url" => ["http://SomeRelatedWebURL.org/Resource.id01"],
        "see_also" => ["LN02323", "PG23442"],
        "extent" => ["Filesize: 123KB", "Something else"],
        "rights" => ["Rights 1", "Rights 2"]
      } 
      @generic_content.update_attributes( attributes_hash )

      # Marked as 'unique' in the call to delegate... 
      @generic_content.title.should == attributes_hash["title"]
      @generic_content.description.should == attributes_hash["description"]  
      @generic_content.date_valid.should == attributes_hash["date_valid"]
      @generic_content.language_text.should == attributes_hash["language_text"]
      @generic_content.language_code.should == attributes_hash["language_code"]
      @generic_content.publisher.should == attributes_hash["publisher"]
      @generic_content.resource_status.should == attributes_hash["resource_status"]
      @generic_content.subject_geographic.should == attributes_hash["subject_geographic"]
      @generic_content.subject_temporal.should == attributes_hash["subject_temporal"]
      @generic_content.location_coordinates.should == attributes_hash["location_coordinates"]
      @generic_content.location_label.should == attributes_hash["location_label"]
      @generic_content.location_coordinates_type.should == attributes_hash["location_coordinates_type"]
      @generic_content.genre.should == attributes_hash["genre"]
      @generic_content.type_of_resource.should == attributes_hash["type_of_resource"]
      @generic_content.related_web_url.should == attributes_hash["related_web_url"]
      @generic_content.see_also.should == attributes_hash["see_also"]
      @generic_content.extent.should == attributes_hash["extent"]
      @generic_content.rights.should == attributes_hash["rights"]

      # These attributes are not marked as 'unique' in the call to delegate, results will be arrays...
      @generic_content.person_name.should == attributes_hash["person_name"]
      @generic_content.person_role_text.should == attributes_hash["person_role_text"]
      @generic_content.subject_topic.should == attributes_hash["subject_topic"]  

      @generic_content.save
    end

    it "should respond with validation errors when trying to save without the appropiate fields populated" do
      invalid_attributes_hash = {
        "title" => "",
        "genre" => "",
        "person_name" => [""],
        "person_role_text" => [""],
        "subject_topic" => [""],
        "language_code" => "",
        "language_text" => ""
      }

      @generic_content.update_attributes( invalid_attributes_hash )

      # save should be false
      @generic_content.save.should be_false

      # with 5 error messages
      @generic_content.errors.messages.size.should == 7

      # errors...
      @generic_content.errors.messages[:title].should == ["can't be blank"]
      @generic_content.errors.messages[:genre].should == ["can't be blank"]
      @generic_content.errors.messages[:person_name].should == ["is too short (minimum is 5 characters)"]
      @generic_content.errors.messages[:person_role_text].should == ["is too short (minimum is 3 characters)"]
      @generic_content.errors.messages[:subject_topic].should == ["is too short (minimum is 2 characters)"]
      @generic_content.errors.messages[:language_text].should == ["can't be blank"]
      @generic_content.errors.messages[:language_code].should == ["can't be blank"]    
    end
 
    context "non unique fields" do
      before(:each) do
        @attributes_hash = {
          "title" => "A thesis describing the...",
          "person_name" => ["Smith, John.", "Supervisor, A."],
          "person_role_text" => ["Creator", "Supervisor"],
          "description" => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
          "subject_topic" => ["Subject of the matter"],
          "related_web_url" => ["http://SomeRelatedWebURL.org/Resource.id01"],
          "see_also" => ["LN02323", "PG23442"],
          "extent" => ["Filesize: 123KB", "Something else"],
          "rights" => ["Rights 1", "Rights 2"]

        } 
        @generic_content.update_attributes( @attributes_hash )        
      end
      it "should not overwrite the person_name, person_role_text, subject_topic, related_web_url, see_also, extent & rights if they are not within the attributes" do
        new_attributes_hash = { "title" => "A new title" }
        @generic_content.update_attributes( new_attributes_hash )
        @generic_content.title.should == new_attributes_hash["title"]
        @generic_content.person_name.should ==  @attributes_hash["person_name"]
        @generic_content.person_role_text.should == @attributes_hash["person_role_text"]
        @generic_content.subject_topic.should == @attributes_hash["subject_topic"]
        @generic_content.related_web_url.should == @attributes_hash["related_web_url"]
        @generic_content.see_also.should == @attributes_hash["see_also"]
        @generic_content.extent.should == @attributes_hash["extent"]
        @generic_content.rights.should == @attributes_hash["rights"]
      end

    end

  end

  context "methods" do
      before(:each) do
        #set the 'required' fields
        @valid_generic_content  =  GenericContent.new
        @valid_generic_content.title = "Test title"
        @valid_generic_content.person_name = ["Smith, John.", "Jones, John"]
        @valid_generic_content.person_role_text = ["Author", "Author"]
        @valid_generic_content.subject_topic = ["Topic 1"]
        @valid_generic_content.language_code = "eng"
        @valid_generic_content.language_text = "English"
        @valid_generic_content.genre = "Presentation"
        @valid_generic_content.save
      end
      after(:each) do
        @valid_generic_content.delete
      end
      describe ".to_solr" do
        it "should return the necessary facets" do
          solr_doc = @valid_generic_content.to_solr
          solr_doc["object_type_sim"].should == "Presentation"
        end

        it "should return the necessary cModels" do
          solr_doc = @valid_generic_content.to_solr
          solr_doc["has_model_ssim"].should == ["info:fedora/hull-cModel:presentation", "info:fedora/hydra-cModel:compoundContent", "info:fedora/hydra-cModel:commonMetadata"]
        end
      end
      describe ".save" do
        it "should create the appropriate cModel declarations" do       
          @valid_generic_content.ids_for_outbound(:has_model).should == ["hull-cModel:presentation", "hydra-cModel:compoundContent", "hydra-cModel:commonMetadata"] 
        end
        it "should contain the appropiately case for the journalArticle in the RELS-EXT (Lower Camelcase)" do
          @valid_generic_content.rels_ext.to_rels_ext.include?('info:fedora/hull-cModel:presentation').should == true
        end       
      end
     
  end

  context "resource_state" do
    before(:each) do
      #set the general 'required' fields for an object
      @valid_generic_content  =  GenericContent.new
      @valid_generic_content.title = "Test title"
      @valid_generic_content.person_name = ["Smith, John.", "Jones, John"]
      @valid_generic_content.person_role_text = ["Author", "Author"]
      @valid_generic_content.subject_topic = ["Topic 1"]
      @valid_generic_content.language_code = "eng"
      @valid_generic_content.language_text = "English"
      @valid_generic_content.genre = "Presentation"
      @valid_generic_content.save
    end

    after(:each) do
      @valid_generic_content.delete
    end

    describe "hidden" do
      it "should validate that the required field 'resource status' is populated" do

        #Submit the resource so that it can be hidden... 
        @valid_generic_content.submit_resource
        #Save the state... 
        @valid_generic_content.save
        
        @valid_generic_content.resource_state.should == "qa"

        #Hide the resource...
        @valid_generic_content.hide_resource.should be_true
        
        #Save should fail because of the validation state callback
        @valid_generic_content.save.should be_false
        @valid_generic_content.errors.messages[:resource_status].should == ["can't be blank"]
        
        #Populate thteh required field
        @valid_generic_content.resource_status = "Hidden due to Copyright enquiry"
        #Save should work...
        @valid_generic_content.save.should be_true
      end
    end

    describe "deleted" do
      it "should validate that the required field 'resource status' is populated" do
        #Submit the resource so that it can be hidden... 
        @valid_generic_content.submit_resource
        @valid_generic_content.publish_resource
        #Save the state... 
        @valid_generic_content.save

        @valid_generic_content.resource_state.should == "published"

        #'Delete' the resource...
        @valid_generic_content.delete_resource.should be_true
        
        #Save should fail because of the validation state callback
        @valid_generic_content.save.should be_false
        @valid_generic_content.errors.messages[:resource_status].should == ["can't be blank"]

        #Populate thteh required field
        @valid_generic_content.resource_status = "Deleted due to duplicate record"
        #Save should work...
        @valid_generic_content.save.should be_true
      end
    end

  end

end

