# encoding: utf-8
# spec/models/journal_article_spec.rb
require 'spec_helper'

describe JournalArticle do
  
  context "original spec" do
    before(:each) do
      # Create a new Journal artcle object for the tests... 
      @ja = JournalArticle.new
    end

    it "should have the specified datastreams" do
      #Check for descMetadata datastream
      @ja.datastreams.keys.should include("descMetadata")
      @ja.descMetadata.should be_kind_of Datastream::ModsJournalArticle
      @ja.descMetadata.label.should == "MODS metadata"

      #Check for contentMetadata datastream
      @ja.datastreams.keys.should include("contentMetadata")
      @ja.contentMetadata.should be_kind_of Hyhull::Datastream::ContentMetadata

      #Check for the rightsMetadata datastream
      @ja.datastreams.keys.should include("rightsMetadata")
      @ja.rightsMetadata.should be_kind_of Hydra::Datastream::RightsMetadata
      @ja.rightsMetadata.label.should == "Rights metadata"

      #Check for the properties datastream
      @ja.datastreams.keys.should include("properties")
      @ja.properties.should be_kind_of Hyhull::Datastream::WorkflowProperties
    end

    it "should include Full text Indexable behaviour" do
      @ja.class.ancestors.should include(Hyhull::FullTextIndexableBehaviour)
    end

    it "genre should be set to 'Journal article'" do
      @ja.genre.should == "Journal article"
    end

    it "should have the attributes of an Journal article and support update_attributes" do
      attributes_hash = {
        "title" => "A thesis describing the...",
        "person_name" => ["Smith, John.", "Supervisor, A."],
        "person_role_text" => ["Author", "Supervisor"],
        "person_affiliation" => ["University of Hull", "Law School"],
        "abstract" => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        "subject_topic" => ["Subject of the matter"],    
        "date_issued" => "1983-03-01",
        "language_text" => "English",
        "language_code" => "eng",
        "publisher" => "ICTD, The University of Hull",
        "resource_status" => "New nice object",
        "peer_reviewed" => "false",
        "journal_title" => "The title of the Journal",
        "journal_publisher" => "The Publisher of the journal",
        "journal_publication_date" => "2010",
        "journal_print_issn" => "12345",
        "journal_electronic_issn" => "x12345x",
        "journal_article_doi" => "doi:123455a",
        "journal_volume" => "1",
        "journal_issue" => "2",
        "journal_start_page" => "100",
        "journal_end_page" => "200",
        "journal_article_restriction" => "No restriction",
        "journal_publications_note" => "To access this article...",
        "journal_url" => ["http://sample.com/pdf", "http://sample.com/abstract"],
        "journal_url_access" => ["raw object", "preview"],
        "journal_url_display_label" => ["Full text", "Abstract"], 
        "converis_publication_id" => "123456", 
        "unit_of_assessment" => "UoA 15",
        "apc" => "Paid",
        "project_id" => "1234a",
        "project_funder_id" => "5678b",
        "project_funder_name" => "A funder name",
        "free_to_read_start_date" => "2015-11-15",
        "free_to_read_end_date" => "2016-11-15",
        "licence_url" => "http://licence-url.com",
        "licence_ref_start_date" => "2016-03-21"
      } 

      @ja.update_attributes( attributes_hash )

      # Marked as 'unique' in the call to delegate... 
      @ja.title.should == attributes_hash["title"]
      @ja.abstract.should == attributes_hash["abstract"]  
      @ja.date_issued.should == attributes_hash["date_issued"]
      @ja.language_text.should == attributes_hash["language_text"]
      @ja.language_code.should == attributes_hash["language_code"]
      @ja.publisher.should == attributes_hash["publisher"]
      @ja.resource_status.should == attributes_hash["resource_status"]

      @ja.peer_reviewed.should == attributes_hash["peer_reviewed"]
      @ja.journal_title.should == attributes_hash["journal_title"]
      @ja.journal_publisher.should == attributes_hash["journal_publisher"]
      @ja.journal_publication_date.should == attributes_hash["journal_publication_date"]
      @ja.journal_print_issn.should == attributes_hash["journal_print_issn"]
      @ja.journal_electronic_issn.should == attributes_hash["journal_electronic_issn"]
      @ja.journal_article_doi.should == attributes_hash["journal_article_doi"]
      @ja.journal_volume.should == attributes_hash["journal_volume"]
      @ja.journal_issue.should == attributes_hash["journal_issue"]
      @ja.journal_start_page.should == attributes_hash["journal_start_page"]
      @ja.journal_end_page.should == attributes_hash["journal_end_page"]
      @ja.journal_article_restriction.should == attributes_hash["journal_article_restriction"]
      @ja.journal_publications_note.should == attributes_hash["journal_publications_note"]

      # These attributes are not marked as 'unique' in the call to delegate, results will be arrays...
      @ja.person_name.should == attributes_hash["person_name"]
      @ja.person_role_text.should == attributes_hash["person_role_text"]
      @ja.person_affiliation.should == attributes_hash["person_affiliation"]
      @ja.subject_topic.should == attributes_hash["subject_topic"]  

      @ja.journal_url.should == attributes_hash["journal_url"]
      @ja.journal_url_access.should == attributes_hash["journal_url_access"]
      @ja.journal_url_display_label.should == attributes_hash["journal_url_display_label"]

      @ja.unit_of_assessment.should == attributes_hash["unit_of_assessment"]
      @ja.converis_publication_id.should == attributes_hash["converis_publication_id"]

      # RIOXX
      @ja.apc == attributes_hash["apc"]
      @ja.project_id == attributes_hash["project_id"]
      @ja.project_funder_id == attributes_hash["project_funder_id"]
      @ja.project_funder_name == attributes_hash["project_funder_name"]
      @ja.free_to_read_start_date == attributes_hash["free_to_read_start_date"]
      @ja.free_to_read_end_date == attributes_hash["free_to_read_end_date"]
      @ja.licence_url == attributes_hash["licence_url"]
      @ja.licence_ref_start_date == attributes_hash["2016-03-21"]

      @ja.save
    end

    it "should respond with validation errors when trying to save without the appropiate fields populated" do
      invalid_attributes_hash = {
        "title" => "",
        "person_name" => [""],
        "person_role_text" => [""],
        "person_affiliation" => [""],
        "subject_topic" => [""],
        "publisher" => "",
        "free_to_read_start_date" => "01-01-01",
        "free_to_read_end_date" => "01-01-01",
        "licence_ref_start_date" => "01-01-01"
      }

      @ja.update_attributes( invalid_attributes_hash )

      # save should be false
      @ja.save.should be_false

      # with 7 error messages
      @ja.errors.messages.size.should == 8

      # errors...
      @ja.errors.messages[:title].should == ["can't be blank"]
      @ja.errors.messages[:person_name].should == ["is too short (minimum is 3 characters)"]
      @ja.errors.messages[:person_role_text].should == ["is too short (minimum is 3 characters)"]
      @ja.errors.messages[:person_affiliation].should be_nil
      @ja.errors.messages[:subject_topic].should == ["is too short (minimum is 2 characters)"]
      @ja.errors.messages[:publisher].should == ["can't be blank"]
      @ja.errors.messages[:free_to_read_start_date].should == ["is invalid"]
      @ja.errors.messages[:free_to_read_end_date].should == ["is invalid"]
      @ja.errors.messages[:licence_ref_start_date].should == ["is invalid"]
    end

    context "non unique fields" do
      before(:each) do
        @attributes_hash = {
          "title" => "A thesis describing the...",
          "person_name" => ["Smith, John.", "Supervisor, A."],
          "person_role_text" => ["Creator", "Supervisor"],
          "person_affiliation" => ["", "Law School"],
          "abstract" => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
          "subject_topic" => ["Subject of the matter"],
          "journal_url" => ["http://sample.com/pdf", "http://sample.com/abstract"],
          "journal_url_access" => ["raw object", "preview"],
          "journal_url_display_label" => ["Full text", "Abstract"],
          "project_id" => ["1234a"],
          "project_funder_id" => ["5678b"],
          "project_funder_name" => ["A funder name"],
          "free_to_read_start_date" => ["2015-11-07"],
          "free_to_read_end_date" => ["2016-11-07"],
          "licence_url" => ["http://licence-url.com"],
          "licence_ref_start_date" => ["2016-03-21"]
        } 
        @ja.update_attributes( @attributes_hash )        
      end
      it "should not overwrite the person_name, person_role_text and person_affiliation if they are not within the attributes" do
        new_attributes_hash = { "title" => "A new title" }
        @ja.update_attributes( new_attributes_hash )
        @ja.title.should == new_attributes_hash["title"]
        @ja.person_name.should ==  @attributes_hash["person_name"]
        @ja.person_role_text.should == @attributes_hash["person_role_text"]
        @ja.person_affiliation.should == @attributes_hash["person_affiliation"]
      end

      it "should not overwrite the subject_topic if they are not within the attributes" do
        new_attributes_hash = { "title" => "A new title part 2" }
        @ja.update_attributes( new_attributes_hash )
        @ja.title.should == new_attributes_hash["title"]
        @ja.subject_topic.should == @attributes_hash["subject_topic"]
      end   

      it "should not overwrite the grant_number if they are not within the attributes" do
        new_attributes_hash = { "title" => "A new title part 3" }
        @ja.update_attributes( new_attributes_hash )
        @ja.title.should == new_attributes_hash["title"]
      end

      it "should not overwrite the journal urls if they are not within the attributes" do
        new_attributes_hash = { "title" => "A new title part 3" }
        @ja.update_attributes( new_attributes_hash )

        @ja.title.should == new_attributes_hash["title"]
        @ja.journal_url.should == @attributes_hash["journal_url"]
        @ja.journal_url_access.should == @attributes_hash["journal_url_access"]
        @ja.journal_url_display_label.should == @attributes_hash["journal_url_display_label"]
      end
    end

  end

  context "methods" do
      before(:each) do
          #set the 'required' fields
          @valid_ja  =  JournalArticle.new
          @valid_ja.title = "Test title"
          @valid_ja.person_name = ["Smith, John.", "Jones, John"]
          @valid_ja.person_role_text = ["Author", "Author"]
          @valid_ja.person_affiliation = ["", "Department of History"]
          @valid_ja.subject_topic = ["Topic 1"]
          @valid_ja.language_code = "eng"
          @valid_ja.language_text = "English"
          @valid_ja.publisher = "IT, UoH"
          @valid_ja.free_to_read_start_date = "2015-11-07"
          @valid_ja.free_to_read_end_date = "2016-11-07"

          @valid_ja.save
      end
      after(:each) do
        @valid_ja.delete
      end
      describe ".to_solr" do
        it "should return the necessary facets" do
          solr_doc = @valid_ja.to_solr
          solr_doc["object_type_sim"].should == "Journal article"
          solr_doc["title_tesim"].should == "Test title"
          solr_doc["publisher_ssm"].should == "IT, UoH"
        end

        it "should return the necessary cModels" do
          solr_doc = @valid_ja.to_solr
          solr_doc["has_model_ssim"].should == ["info:fedora/hydra-cModel:compoundContent", "info:fedora/hydra-cModel:commonMetadata", "info:fedora/hull-cModel:journalArticle"]
        end
      end
      describe ".save" do
        it "should create the appropriate cModel declarations" do       
          @valid_ja.ids_for_outbound(:has_model).should == ["hydra-cModel:compoundContent", "hydra-cModel:commonMetadata", "hull-cModel:journalArticle"] 
        end
        it "should contain the appropiately case for the journalArticle in the RELS-EXT (Lower Camelcase)" do
          @valid_ja.rels_ext.to_rels_ext.include?('info:fedora/hull-cModel:journalArticle').should == true
        end       
      end
     
  end

  context "resource_state" do
    before(:each) do
      #set the general 'required' fields for an object
      @valid_ja  =  JournalArticle.new
      @valid_ja.title = "Test title"
      @valid_ja.person_name = ["Smith, John."]
      @valid_ja.person_role_text = ["Creator"]
      @valid_ja.person_affiliation = ["Business School"]
      @valid_ja.subject_topic = ["Topci 1"]
      @valid_ja.language_code = "eng"
      @valid_ja.language_text = "English"
      @valid_ja.publisher = "IT, UoH"
      @valid_ja.date_issued = "2012"
      @valid_ja.free_to_read_start_date = "2015-11-07"
      @valid_ja.free_to_read_end_date = "2016-11-07"
      @valid_ja.save
    end

    after(:each) do
      @valid_ja.delete
    end

    describe "hidden" do
      it "should validate that the required field 'resource status' is populated" do

        #Submit the resource so that it can be hidden... 
        @valid_ja.submit_resource
        #Save the state... 
        @valid_ja.save
        
        @valid_ja.resource_state.should == "qa"

        #Hide the resource...
        @valid_ja.hide_resource.should be_true
        
        #Save should fail because of the validation state callback
        @valid_ja.save.should be_false
        @valid_ja.errors.messages[:resource_status].should == ["can't be blank"]
        
        #Populate thteh required field
        @valid_ja.resource_status = "Hidden due to Copyright enquiry"
        #Save should work...
        @valid_ja.save.should be_true
      end
    end

    describe "deleted" do
      it "should validate that the required field 'resource status' is populated" do
        #Submit the resource so that it can be hidden... 
        @valid_ja.submit_resource
        @valid_ja.publish_resource
        #Save the state... 
        @valid_ja.save

        @valid_ja.resource_state.should == "published"

        #'Delete' the resource...
        @valid_ja.delete_resource.should be_true
        
        #Save should fail because of the validation state callback
        @valid_ja.save.should be_false
        @valid_ja.errors.messages[:resource_status].should == ["can't be blank"]

        #Populate thteh required field
        @valid_ja.resource_status = "Deleted due to duplicate record"
        #Save should work...
        @valid_ja.save.should be_true
      end
    end

  end

end

