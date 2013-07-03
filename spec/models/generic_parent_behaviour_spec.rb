require 'spec_helper'

class GenericParentBehaviourTest < ActiveFedora::Base
  include Hyhull::GenericParentBehaviour

  def owner_id
    "fooAdmin"
  end

end

describe Hyhull::GenericParentBehaviour do

  context "with the GenericParentBehaviour" do
    describe "datastream_behaviour" do    
      before(:all) do
        @testclassone = GenericParentBehaviourTest.new
      end

      it "should define file_assets methods for setting and retrieving File asset objects" do
        @testclassone.should respond_to :file_assets
        @testclassone.file_assets.should == []
      end
    end

    describe "GenericParentBehaviour#next_asset_pid" do    
      before(:all) do
        @generic_parent = GenericParentBehaviourTest.create
        @pid = @generic_parent.pid
      end
      after(:all) do
        @generic_parent.delete
      end

      it "should return the first available file_asset pid in the correct format" do
        file_asset_pid = @generic_parent.next_asset_pid
        file_asset_pid.should == "#{@pid}a"
      end

      it "should return the next available file_asset pid in the correct format" do
        file_asset =  FileAsset.create(pid: @generic_parent.next_asset_pid) 
        @generic_parent.file_assets << file_asset
        @generic_parent.next_asset_pid.should ==  "#{@pid}b"        
      end 
    end
  end

  context "with the uketd_object hull:756 test fixture" do
    describe "files" do
      before(:all) do
        @generic_parent = UketdObject.find("hull:756")
        @test_file = fixture("hyhull/files/test_pdf_file.pdf")
        @ds = Hyhull::Datastream::ContentMetadata.from_xml(@cm)        
        @test_upload = ActionDispatch::Http::UploadedFile.new({ :filename => 'test_pdf_file.pdf', :type => 'application/pdf', :tempfile => @test_file })
      end
      
      it "should be add-able through the add_file_content(file_data) method" do
        content_metadata_resource_size = @generic_parent.contentMetadata.resource.size
        file_assets_size = @generic_parent.file_assets.size 

        success, file_assets, message = @generic_parent.add_file_content([@test_upload])
        success.should == true
        message.should == "The following files have been added sucessfully to hull:756: [\"test_pdf_file.pdf\"]" 

        @generic_parent.contentMetadata.resource.size.should == (content_metadata_resource_size + 1)
        @generic_parent.file_assets.size.should == (file_assets_size + 1)

        #Check that the FileAsset is as expected...
        file_assets.first.should be_kind_of FileAsset
        file_assets.first.content.mimeType.should == "application/pdf" 

      end

      it "should inherit the rightsMetadata from their parent" do
        success, file_assets, message = @generic_parent.add_file_content([@test_upload])
        # On adding a file, the new FileAsset should inherit the rights of the parent
        @generic_parent.rightsMetadata.groups.should == file_assets.last.rightsMetadata.groups
        @generic_parent.rightsMetadata.individuals.should == file_assets.last.rightsMetadata.individuals
        #@generic_parent.rightsMetadata.content.should == file_assets.last.rightsMetadata.content
      end

      it "should be delete-able through the delete_by_content_metadata_at" do
        content_metadata = @generic_parent.contentMetadata
        resources_size = content_metadata.resource.size
        
        file_asset_object_id = content_metadata.resource(resources_size - 1).resource_object_id[0]
        file_asset_object = FileAsset.find(file_asset_object_id)

        #Should be defined as a file_asset of the @generic_parent
        @generic_parent.file_assets.include?(file_asset_object).should == true
        
        success, deleted_asset_id, message = @generic_parent.delete_by_content_metadata_resource_at(resources_size - 1)

        success.should == true        
        deleted_asset_id.should == file_asset_object_id

        #Should NO longer be defined as a file asset of @generic_parent
        @generic_parent.file_assets.include?(file_asset_object).should == false
        @generic_parent.contentMetadata.resource.size.should == (resources_size - 1)
      end


    end
  end

end


 # def add_file_content(file_data)
 # def delete_by_content_metadata_resource_at(index)
 # update_content_metadata(content_asset, content_ds)