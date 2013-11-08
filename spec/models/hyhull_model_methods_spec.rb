require 'spec_helper'

class ModelMethodsTestClassOne < ActiveFedora::Base
	include Hyhull::ModelMethods

  #Add some attributes to the class to enable some metadata testing
  attr_accessor :title, :date_issued, :date_valid, :genre

	def owner_id
		"fooAdmin"
	end

	def initialize
		super
	end

end

class ModelMethodsTestClassTwo < ActiveFedora::Base
  include Hyhull::ModelMethods

  #Add some attributes to the class to enable some metadata testing
  attr_accessor :title, :date_valid, :genre

  def owner_id
    "fooAdmin"
  end

  def initialize
    super
  end

end

class ModelMethodsTestClassThree < ActiveFedora::Base
  include Hyhull::ModelMethods

  #Add some attributes to the class to enable some metadata testing
  attr_accessor :title, :date_valid, :genre

  has_metadata name: "descMetadata", label: "MODS metadata", type: Datastream::ModsEtd

  def owner_id
    "fooAdmin"
  end

  def initialize
    super
  end




class RightsTestClass < ActiveFedora::Base
  include Hyhull::ModelMethods
  include Hyhull::ResourceWorkflowBehaviour
  include Hyhull::GenericParentBehaviour

  has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata

  def owner_id
    "fooAdmin"
  end

  def initialize
    super
  end
end


describe Hyhull::ModelMethods do

	before(:each) do
		@testclassone = ModelMethodsTestClassOne.new
	end

	describe "cmodel" do
    it "should properly return the appropriate cModel declaration" do
      @testclassone.cmodel.should == "info:fedora/hull-cModel:modelMethodsTestClassOne"
    end
  end

  describe "relationships" do
    it "should define a belongs_to display_set" do
      @testclassone.respond_to?(:display_set).should == true
    end
  end

  context "utility methods" do
    describe "to_long_date" do
      it "should return the appropiate long date versions of the inputted dates" do
        @testclassone.to_long_date("2001").should == "2001-01-01"
        @testclassone.to_long_date("1983-03").should == "1983-03-01"
        @testclassone.to_long_date("1999-05-10").should == "1999-05-10"
      end
    end

    describe "set_deleted_inner_state" do
      before(:each) do
        # We just manually set the state to check it changes correctly
        @testclassone.inner_object.state = "A"
      end
      it "should set the Inner object to Deleted D" do
        @testclassone.set_deleted_inner_state
        @testclassone.state.should == "D"
      end       
    end

    describe "set_active_inner_state" do
      before(:each) do
        # We just manually set the state to check it changes correctly
        @testclassone.inner_object.state = "D"
      end

      it "should set the Inner object to Active A" do
        @testclassone.set_active_inner_state
        @testclassone.state.should == "A"
      end
    end

  end

  context "added datastreams" do
    before(:each) do
      @testclassone.title = "A new test resource"
      @testclassone.date_issued = "2012-01-01"
      @testclassone.date_valid = ""
      @testclassone.genre = "Test asset"
    end
    describe "dc" do
      it "should define the required delegates" do
        @testclassone.respond_to?("dc_title").should be_true
        @testclassone.respond_to?("dc_genre").should be_true
        @testclassone.respond_to?("dc_date").should be_true     
      end
      it "should define the required delegates as unique" do
        @testclassone.dc_title.should == ""
        @testclassone.dc_genre.should == ""
        @testclassone.dc_date.should == ""
      end
      it "should copy title, genre and a date from the base object on save" do
        @testclassone.save
        @testclassone.dc_title.should == "A new test resource"
        #date_issued takes precidence over date_valid
        @testclassone.dc_date.should == "2012-01-01"
        @testclassone.dc_genre.should == "Test asset"
      end
      it "should take a copy of date_valid if date_issued does not exist" do
        testclasstwo = ModelMethodsTestClassTwo.new
        testclasstwo.date_valid = "2020"
        testclasstwo.save
        testclasstwo.dc_date.should == "2020"
      end

    end

  end

  context "additional metadata" do
    describe "apply_depositor_metadata" do
      it "should store the depositor e-mail address along with their user_id" do
        @testclassone.apply_depositor_metadata("usera", "usera@example.com")
        @testclassone.save
        @testclassone.properties.depositor.should == ["usera"]
        @testclassone.properties.depositor_email.should == ["usera@example.com"]
      end
    end

    describe "#apply_resource_object_label" do
      before do
        @testclassthree = ModelMethodsTestClassThree.new
      end
      it "should return an object label based upon the descMetadata title and, names and roles" do
        @testclassthree.title = "This is a test document"
        @testclassthree.descMetadata.add_names(["Smith, John"], ["Creator"], "person")
        @testclassthree.apply_resource_object_label
        @testclassthree.label.should == "This is a test document - Smith, John;"
      end  
      it "should return an object label that is limited to 200 characters" do
        @testclassthree.title = "This is the dataset of all datasets, actually this is a rather large dataset with a title that is likely to be too long for a fedora-label"
        @testclassthree.descMetadata.add_names(["Lamb, Simon.", "Green, Richard.", "Smith, John.", "Garbutt, Richard.", "Jones, Peter.", "Bradfield, James.", "Jones, Nick."], ["Author", "Author", "Author", "Author", "Author", "Author", "Author"], "person")
        @testclassthree.apply_resource_object_label
        @testclassthree.label.should == "This is the dataset of all datasets, actually this is a rather large dataset with a title that is lik... - Lamb, Simon.; Green, Richard.; Smith, John.; Garbutt, Richard.; Jones, Peter.; Bradfield, J..."
      end
    end
  end

  context "permissions" do
   before(:each) do
     @rightstestclass = RightsTestClass.new
     @apo_set = StructuralSet.find("hull-apo:structuralSet")
     @apo_deleted_queue = QueueSet.find("hull:deletedQueue")   
    end
    describe "rightsMetadata" do     
      it "should be set to the depositor by the apply_depositor_metadata method" do
        @rightstestclass.apply_depositor_metadata("testUser","testUser@example.com")
        @rightstestclass.rightsMetadata.groups.should == {}
        @rightstestclass.rightsMetadata.individuals.should == {"testUser" => "edit"}
      end
      it "should not be set if the instance.apply_permissions exists and is set to false" do
        @rightstestclass.rightsMetadata.groups.should == {}
        @rightstestclass.apply_permissions = false
        @rightstestclass.apo = @apo_set
        
        @rightstestclass.apply_rights_metadata_from_apo
        # Rights metadata should not change...
        @rightstestclass.rightsMetadata.groups.should == {}
      end

      it "should be set if the instance.apply_permissions exists and is set to true" do
        @rightstestclass.rightsMetadata.groups.should == {}
        @rightstestclass.apply_permissions = true
        @rightstestclass.apo = @apo_set
        
        @rightstestclass.apply_rights_metadata_from_apo
        # Rights metadata should change...
        @rightstestclass.rightsMetadata.groups.should == {"contentAccessTeam" => "edit"}
      end

      it "should set a resources rightsMetadata based upon the APO" do
        @rightstestclass.apo = @apo_set
        # Manually set the apply_permissions bool
        @rightstestclass.apply_permissions = true
        @rightstestclass.apply_rights_metadata_from_apo

        @rightstestclass.rightsMetadata.groups.should == {"contentAccessTeam" => "edit"}
        @rightstestclass.rightsMetadata.individuals.should == {}

        @rightstestclass.apo = @apo_deleted_queue
        # Manually set the apply_permissions bool
        @rightstestclass.apply_permissions = true
        @rightstestclass.apply_rights_metadata_from_apo

        @rightstestclass.rightsMetadata.groups.should == {"admin" => "edit"}
        @rightstestclass.rightsMetadata.individuals.should == {}
      end
      # Testing for for FileAssets rightsMetadata changes on GenericParents
      it "apply_permissions should set a GenericParent rightsMetadata and its FileAssets rights based upon the APO" do
        file_asset = FileAsset.create
        @rightstestclass.apo = @apo_set
        @rightstestclass.file_assets << file_asset
        # Manually set the apply_permissions bool
        @rightstestclass.apply_permissions = true

        @rightstestclass.apply_rights_metadata_from_apo 

        file_asset.rightsMetadata.groups.should == {"contentAccessTeam" => "edit"}
        file_asset.rightsMetadata.individuals.should == {}

        @rightstestclass.apo = @apo_deleted_queue
        # Manually set the apply_permissions bool
        @rightstestclass.apply_permissions = true
        @rightstestclass.apply_rights_metadata_from_apo

        file_asset.rightsMetadata.groups.should == {"admin" => "edit"}
        file_asset.rightsMetadata.individuals.should == {}      
      end

      it "should be updatable via the update_resource_permissions method" do
        # Clears the pemissions.. 
        @rightstestclass.rightsMetadata.clear_permissions!
        # Create some permission params
        params = {"group" => {"public" => "discover", "staff" => "read", "contentAccessTeam" => "edit"}}

        @rightstestclass.update_resource_permissions(params, "rightsMetadata") 
        @rightstestclass.rightsMetadata.groups.should == {"public" => "discover", "staff" => "read", "contentAccessTeam" => "edit"}
      
      end

      it "should be updated via the update_resource_permissions method for a GenericParent and its fileAssets" do
        # Create file asset..
        file_asset_one = FileAsset.create
        file_asset_two = FileAsset.create 
        # Add them to the rightstestclass...
        @rightstestclass.file_assets = [file_asset_one, file_asset_two]

        # Clears the pemissions...
        @rightstestclass.rightsMetadata.clear_permissions!
        # Create some permission params
        params = {"group" => {"public" => "discover", "staff" => "read", "contentAccessTeam" => "edit"}}

        @rightstestclass.update_resource_permissions(params, "rightsMetadata") 

        file_asset_one.rightsMetadata.groups.should == {"public" => "discover", "staff" => "read", "contentAccessTeam" => "edit"}
        file_asset_two.rightsMetadata.groups.should == {"public" => "discover", "staff" => "read", "contentAccessTeam" => "edit"}
      end

    end
   
  end

end

end
