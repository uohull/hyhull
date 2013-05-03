# spec/models/uketd_spec.rb
require 'spec_helper'

describe UketdObject do
  
  context "original spec" do
    before(:each) do
      # Create a new etd object for the tests... 
      @etd = UketdObject.new
    end

    it "should have the specified datastreams" do

      #Check for descMetadata datastream
      @etd.datastreams.keys.should include("descMetadata")
      @etd.descMetadata.should be_kind_of Datastream::ModsEtd

      #Check for contentMetadata datastream
      @etd.datastreams.keys.should include("contentMetadata")
      @etd.contentMetadata.should be_kind_of Hyhull::Datastream::ContentMetadata

      #Check for the rightsMetadata datastream
      @etd.datastreams.keys.should include("rightsMetadata")
      @etd.rightsMetadata.should be_kind_of Hydra::Datastream::RightsMetadata

      #Check for the properties datastream
      #@etd.datastreams.key.should include ("properties")
      #@etd.datastreams.should be_kind_of ActiveFedora::MetadataDatastream
    end

    it "should have the attributes of an etd object and support update_attributes" do
      attributes_hash = {
        "title" => "A thesis describing the...",
        "person_name" => ["Smith, John.", "Supervisor, A."],
        "person_role_text" => ["Creator", "Supervisor"],
        "organisation_name" => ["The University of Hull"],
        "organisation_role_text" =>["Funder"],
        "abstract" => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        "subject_topic" => ["Subject of the matter"],
        "grant_number" => "GN:122335",
        "ethos_identifier" => "EthosId:Test:009",       
        "date_issued" => "1983-03-01",
        "qualification_level" => "Doctoral",
        "qualification_name" => "PhD",
        "dissertation_category" => "",
        "language_text" => "English",
        "language_code" => "eng",
        "publisher" => "ICTD, The University of Hull"
      } 

      @etd.update_attributes( attributes_hash )

      # Marked as 'unique' in the call to delegate... 
      @etd.title.should == attributes_hash["title"]
      @etd.abstract.should == attributes_hash["abstract"]  
      @etd.ethos_identifier == attributes_hash["ethos_identifier"]
      @etd.date_issued == attributes_hash["date_issued"]
      @etd.qualification_level == attributes_hash["qualification_level"]
      @etd.qualification_name == attributes_hash["qualification_name"]
      @etd.dissertation_category == attributes_hash["dissertation_category"]
      @etd.language_text == attributes_hash["language_text"]
      @etd.language_code == attributes_hash["language_code"]
      @etd.publisher == attributes_hash["publisher"]

      # These attributes are not marked as 'unique' in the call to delegate, results will be arrays...
      @etd.person_name.should == attributes_hash["person_name"]
      @etd.person_role_text.should == attributes_hash["person_role_text"]
      @etd.organisation_name.should == attributes_hash["organisation_name"]
      @etd.organisation_role_text.should == attributes_hash["organisation_role_text"]
      @etd.subject_topic.should == attributes_hash["subject_topic"]  
      @etd.grant_number == [attributes_hash["grant_number"]]

      @etd.save
    end
    
    describe ".to_solr" do
      it "should return the necessary facets" do
        solr_doc = @etd.to_solr
        solr_doc["object_type_sim"].should == "Thesis or dissertation"
      end

      it "should return the necessary cModels" do
         @etd.save
        solr_doc = @etd.to_solr
        solr_doc["has_model_ssim"].should == ["info:fedora/hydra-cModel:commonMetadata", "info:fedora/hydra-cModel:genericParent", "info:fedora/hull-cModel:uketdObject"]
      end

    end

    describe ".save" do
      before(:each) do
        @etd.save
      end
      it "should create the appropriate cModel declarations" do       
        @etd.ids_for_outbound(:has_model).should == ["hydra-cModel:commonMetadata", "hydra-cModel:genericParent", "hull-cModel:uketdObject"] 
      end
      it "should contain the appropiately case for the uketdObject in the RELS-EXT (Lower Camelcase)" do
        @etd.rels_ext.to_rels_ext.include?('info:fedora/hull-cModel:uketdObject').should == true
      end
    end
  end
end