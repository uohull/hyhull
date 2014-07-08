# encoding: utf-8
# spec/models/dataset_spec.rb
require 'spec_helper'

describe Dataset do
  
  context "original spec" do
    before(:each) do
      # Create a new Generic Content object for the tests... 
      @dataset = Dataset.new
    end

    it "is a specialised GenericContent" do
      @dataset.kind_of? GenericContent
    end

    it "should have the specified datastreams" do
      #Check for descMetadata datastream
      @dataset.datastreams.keys.should include("descMetadata")
      @dataset.descMetadata.should be_kind_of Datastream::ModsDataset
      @dataset.descMetadata.label.should == "MODS metadata"

      #Check for contentMetadata datastream
      @dataset.datastreams.keys.should include("contentMetadata")
      @dataset.contentMetadata.should be_kind_of Hyhull::Datastream::ContentMetadata

      #Check for the rightsMetadata datastream
      @dataset.datastreams.keys.should include("rightsMetadata")
      @dataset.rightsMetadata.should be_kind_of Hydra::Datastream::RightsMetadata
      @dataset.rightsMetadata.label.should == "Rights metadata"

      #Check for the properties datastream
      @dataset.datastreams.keys.should include("properties")
      @dataset.properties.should be_kind_of Hyhull::Datastream::WorkflowProperties
    end

    it "should include Full text Indexable behaviour" do
      @dataset.class.ancestors.should include(Hyhull::FullTextIndexableBehaviour)
    end

    it "genre should be set to 'Dataset'" do
      @dataset.genre.should == "Dataset"
    end

    # This is a copy of the GenericContent test - (Dataset < GenericContent)
    it "should have the attributes of an Generic Content and support update_attributes" do
      attributes_hash = {
        "title" => "A thesis describing the...",
        "version" => "Version 1.0",
        "person_name" => ["Smith, John.", "Supervisor, A."],
        "person_role_text" => ["Author", "Supervisor"],
        "organisation_name" => ["The University of Hull"],
        "organisation_role_text" =>["Funder"],
        "description" => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        "subject_topic" => ["Subject of the matter"], 
        "subject_geographic" => ["Hull", "Kingston Upon Hull"],
        "subject_temporal" => ["2013", "August"],
        "location_coordinates" => "12, 10",
        "location_label" => "The location label",
        "location_coordinates_type" => "Point",
        "genre" => "Presentation",
        "type_of_resource" => "text",
        "date_valid" => "1983-03-01",
        "language_text" => "English",
        "language_code" => "eng",
        "doi" => "This doi is:1245",        
        "publisher" => "ICTD, The University of Hull",
        "resource_status" => "New nice object",        
        "related_web_url" => ["http://SomeRelatedWebURL.org/Resource.id01"],
        "see_also" => ["LN02323", "PG23442"],
        "extent" => ["Filesize: 123KB", "Something else"],
        "rights" => ["Rights 1", "Rights 2"],
        "citation" => ["Citation 1", "Citation 2"],
        "software" => ["Linux", "Ubuntu"],
        "converis_publication_id" => "123456"
      } 
      @dataset.update_attributes( attributes_hash )

      # Marked as 'unique' in the call to delegate... 
      @dataset.title.should == attributes_hash["title"]
      @dataset.version.should == attributes_hash["version"]      
      @dataset.description.should == attributes_hash["description"]  
      @dataset.date_valid.should == attributes_hash["date_valid"]
      @dataset.language_text.should == attributes_hash["language_text"]
      @dataset.language_code.should == attributes_hash["language_code"] 
      @dataset.publisher.should == attributes_hash["publisher"]
      @dataset.resource_status.should == attributes_hash["resource_status"]
      @dataset.location_coordinates.should == attributes_hash["location_coordinates"]
      @dataset.location_label.should == attributes_hash["location_label"]
      @dataset.location_coordinates_type.should == attributes_hash["location_coordinates_type"]
      @dataset.genre.should == attributes_hash["genre"]
      @dataset.type_of_resource.should == attributes_hash["type_of_resource"]
      @dataset.related_web_url.should == attributes_hash["related_web_url"]
      @dataset.see_also.should == attributes_hash["see_also"]
      @dataset.extent.should == attributes_hash["extent"]
      @dataset.rights.should == attributes_hash["rights"]
      @dataset.doi.should == attributes_hash["doi"]
      @dataset.converis_publication_id.should == attributes_hash["converis_publication_id"]

      # These attributes are not marked as 'unique' in the call to delegate, results will be arrays...
      @dataset.person_name.should == attributes_hash["person_name"]
      @dataset.person_role_text.should == attributes_hash["person_role_text"]
      @dataset.organisation_name.should == attributes_hash["organisation_name"]
      @dataset.organisation_role_text.should == attributes_hash["organisation_role_text"]
      @dataset.subject_topic.should == attributes_hash["subject_topic"] 
      @dataset.subject_geographic.should == attributes_hash["subject_geographic"]
      @dataset.subject_temporal.should == attributes_hash["subject_temporal"]
      @dataset.citation.should == attributes_hash["citation"]
      @dataset.software.should == attributes_hash["software"]
      @dataset.save
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

      @dataset.update_attributes( invalid_attributes_hash )

      # save should be false
      @dataset.save.should be_false

      # with 5 error messages
      @dataset.errors.messages.size.should == 5

      # errors...
      @dataset.errors.messages[:title].should == ["can't be blank"]
      @dataset.errors.messages[:genre].should == ["can't be blank"]
      @dataset.errors.messages[:subject_topic].should == ["is too short (minimum is 2 characters)"]
      @dataset.errors.messages[:language_text].should == ["can't be blank"]
      @dataset.errors.messages[:language_code].should == ["can't be blank"]    
    end


    describe "assert_content_model" do
      it "should set the cModels" do
        @dataset.relationships(:has_model).should == []
        @dataset.assert_content_model
        @dataset.relationships(:has_model).should == ["info:fedora/hull-cModel:dataset", "info:fedora/hydra-cModel:compoundContent", "info:fedora/hydra-cModel:commonMetadata"]
        @dataset.assert_content_model ## Shouldn't add another row.
        @dataset.relationships(:has_model).should == ["info:fedora/hull-cModel:dataset", "info:fedora/hydra-cModel:compoundContent", "info:fedora/hydra-cModel:commonMetadata"]
      end
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
          "rights" => ["Rights 1", "Rights 2"],
          "subject_geographic" => ["East Riding of Yorkshire", "Kingston Upon Hull"],
          "subject_temporal" => ["19th Century", "1900's"],
          "citation" => ["Cite as: This", "Cite as: that"],
          "software" => ["Windows 8", "Microsoft Excel"],

        } 
        @dataset.update_attributes( @attributes_hash )        
      end
      it "should not overwrite the person_name, person_role_text, subject_topic, related_web_url, see_also, extent & rights if they are not within the attributes" do
        new_attributes_hash = { "title" => "A new title" }
        @dataset.update_attributes( new_attributes_hash )
        @dataset.title.should == new_attributes_hash["title"]
        @dataset.person_name.should ==  @attributes_hash["person_name"]
        @dataset.person_role_text.should == @attributes_hash["person_role_text"]
        @dataset.subject_topic.should == @attributes_hash["subject_topic"]
        @dataset.related_web_url.should == @attributes_hash["related_web_url"]
        @dataset.see_also.should == @attributes_hash["see_also"]
        @dataset.extent.should == @attributes_hash["extent"]
        @dataset.rights.should == @attributes_hash["rights"]
        @dataset.subject_geographic.should == @attributes_hash["subject_geographic"]
        @dataset.subject_temporal.should == @attributes_hash["subject_temporal"]
        @dataset.citation.should == @attributes_hash["citation"]
        @dataset.software.should == @attributes_hash["software"]
      end

    end

  end

  context "methods" do
      before(:each) do
        #set the 'required' fields
        @valid_dataset  =  Dataset.new
        @valid_dataset.title = "Test title"
        @valid_dataset.person_name = ["Smith, John.", "Jones, John"]
        @valid_dataset.person_role_text = ["Author", "Author"]
        @valid_dataset.subject_topic = ["Topic 1"]
        @valid_dataset.language_code = "eng"
        @valid_dataset.language_text = "English"
        @valid_dataset.save
      end
      after(:each) do
        @valid_dataset.delete
      end
      describe ".to_solr" do
        it "should return the necessary facets" do
          solr_doc = @valid_dataset.to_solr
          solr_doc["object_type_sim"].should == "Dataset"
        end

        it "should return the necessary cModels" do
          solr_doc = @valid_dataset.to_solr
          solr_doc["has_model_ssim"].should == ["info:fedora/hull-cModel:dataset", "info:fedora/hydra-cModel:compoundContent", "info:fedora/hydra-cModel:commonMetadata"]
        end
      end
      describe ".save" do
        it "should create the appropriate cModel declarations" do       
          @valid_dataset.ids_for_outbound(:has_model).should == ["hull-cModel:dataset", "hydra-cModel:compoundContent", "hydra-cModel:commonMetadata"] 
        end
        it "should contain the appropiately case for the dataset in the RELS-EXT (Lower Camelcase)" do
          @valid_dataset.rels_ext.to_rels_ext.include?('info:fedora/hull-cModel:dataset').should == true
        end
      end
     
  end

  context "resource_state" do
    before(:each) do
      #set the general 'required' fields for an object
      @valid_dataset =  Dataset.new
      @valid_dataset.title = "Test title"
      @valid_dataset.person_name = ["Smith, John.", "Jones, John"]
      @valid_dataset.person_role_text = ["Author", "Author"]
      @valid_dataset.subject_topic = ["Topic 1"]
      @valid_dataset.language_code = "eng"
      @valid_dataset.language_text = "English"
      @valid_dataset.save
    end

    after(:each) do
      @valid_dataset.delete
    end

    describe "hidden" do
      it "should validate that the required field 'resource status' is populated" do

        #Submit the resource so that it can be hidden... 
        @valid_dataset.submit_resource
        #Save the state... 
        @valid_dataset.save
        
        @valid_dataset.resource_state.should == "qa"

        #Hide the resource...
        @valid_dataset.hide_resource.should be_true
        
        #Save should fail because of the validation state callback
        @valid_dataset.save.should be_false
        @valid_dataset.errors.messages[:resource_status].should == ["can't be blank"]
        
        #Populate thteh required field
        @valid_dataset.resource_status = "Hidden due to Copyright enquiry"
        #Save should work...
        @valid_dataset.save.should be_true
      end
    end

    describe "deleted" do
      it "should validate that the required field 'resource status' is populated" do
        #Submit the resource so that it can be hidden... 
        @valid_dataset.submit_resource
        @valid_dataset.publish_resource
        #Save the state... 
        @valid_dataset.save

        @valid_dataset.resource_state.should == "published"

        #'Delete' the resource...
        @valid_dataset.delete_resource.should be_true
        
        #Save should fail because of the validation state callback
        @valid_dataset.save.should be_false
        @valid_dataset.errors.messages[:resource_status].should == ["can't be blank"]

        #Populate thteh required field
        @valid_dataset.resource_status = "Deleted due to duplicate record"
        #Save should work...
        @valid_dataset.save.should be_true
      end
    end

  end

end

