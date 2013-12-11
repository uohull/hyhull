require 'spec_helper'

class ContentMetadataBehaviourTest < ActiveFedora::Base
  include Hyhull::ContentMetadataBehaviour
  include Hyhull::GenericParentBehaviour

  def owner_id
    "fooAdmin"
  end

end

describe Hyhull::ModelMethods do

  before(:each) do
    @testclassone = ContentMetadataBehaviourTest.new
  end

  describe "datastream_behaviour" do
    it "should define the contentMetadata Hyhull::Datastream::ContentMetadata as a metadata datastream" do
      @testclassone.datastreams.should include('contentMetadata')
      @testclassone.contentMetadata.should be_an_instance_of(Hyhull::Datastream::ContentMetadata)
      @testclassone.contentMetadata.label.should == "Content metadata"
    end
  end

  describe "delegates" do
    it "should return the appropiate delegates" do
      @testclassone.sequence.should == []
      @testclassone.resource_display_label.should == []
      @testclassone.resource_object_id.should == []
      @testclassone.resource_ds_id.should == []
      @testclassone.content_id.should == []
    end
  end

  describe "adding content metadata based upon a file_asset content datastream" do
    before(:all) do
      #Create some valid test objects  
      @test_object = ContentMetadataBehaviourTest.create       
      @file_asset = FileAsset.create

      @test_file = fixture("hyhull/files/test_pdf_file.pdf") 
      @file_name = File.basename(@test_file)
      # Changed ds to content_test to test behaviour below...
      @file_asset.add_file(@test_file, "content_test", @file_name)
      @file_asset.save
    end

    it "should raise an exception when an invalid object is a parameter" do
      expect {
        @testclassone.add_content_metadata("Randon object", "Randon ds")
      }.to raise_error("Content Metadata can only be derived from ActiveFedora::Base objects")
    end

    it "should add appropiate content metadata for valid object" do
      @test_object.add_content_metadata(@file_asset, "content_test").should == 0

      @test_object.contentMetadata.resource.size.should == 1

      @test_object.contentMetadata.sequence.first.should == "1"
      @test_object.contentMetadata.content_size.first.should == @test_file.size.to_s
      @test_object.contentMetadata.content_mime_type.first.should == "application/pdf"
      @test_object.contentMetadata.content_format.first.should == "pdf"
      @test_object.contentMetadata.resource_object_id.first.should == @file_asset.pid
      @test_object.contentMetadata.resource_ds_id.first.should == "content_test"
      @test_object.contentMetadata.resource.file.location.first.should == "http://hydra.hull.ac.uk/assets/#{@file_asset.pid}/content_test"
      @test_object.contentMetadata.resource.diss_service_def.first.should == "afmodel:FileAsset"
      @test_object.contentMetadata.resource.diss_service_method.first.should == "getContent"
      @test_object.contentMetadata.resource_display_label.first.should == @file_name
      @test_object.contentMetadata.content_id.first.should == @file_name
      @test_object.contentMetadata.resource.file.file_id.first.should == @file_name
    end

    after(:all) do
      @file_asset.delete 
      @test_object.delete
    end

  end

  describe ".get_resource_metadata_hash" do
    before(:each) do
     @sample_resource = ContentMetadataBehaviourTest.find("hull:756")
    end

    it "should return the list of content for the resource by the order of the sequence" do
      content_hash = @sample_resource.get_resource_metadata_hash

      # First item in hash_array
      content_hash[0][:sequence].should == "1"
      content_hash[0][:asset_id].should == "hull:756a"
      content_hash[0][:datastream_id].should == "content"
      content_hash[0][:display_label].should == "Thesis"
      content_hash[0][:mime_type].should == "application/pdf"
      content_hash[0][:content_size].should == "20631"

      # Second item...
      content_hash[1][:sequence].should == "2"
      content_hash[1][:asset_id].should == "hull:756b"
      content_hash[1][:datastream_id].should == "content"
      content_hash[1][:display_label].should == "Scenario 1 video"
      content_hash[1][:mime_type].should == "video/x-ms-wmv"
      content_hash[1][:content_size].should == "779794"

      # Third item
      content_hash[2][:sequence].should == "3"
      content_hash[2][:asset_id].should == "hull:756c"
      content_hash[2][:datastream_id].should == "content"
      content_hash[2][:display_label].should == "Scenario 2 video"
      content_hash[2][:mime_type].should == "video/x-ms-wmv"
      content_hash[2][:content_size].should == "779794"

      # Four item
      content_hash[3][:sequence].should == "4"
      content_hash[3][:asset_id].should == "hull:756d"
      content_hash[3][:datastream_id].should == "content"
      content_hash[3][:display_label].should == "Scenario 3 video"
      content_hash[3][:mime_type].should == "video/x-ms-wmv"
      content_hash[3][:content_size].should == "779794"

    end

  end

end
