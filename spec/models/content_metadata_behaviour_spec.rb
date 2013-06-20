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
    end
  end

  describe "delegates" do
    it "should return the appropiate delegates" do
      @testclassone.sequence.should == []
      @testclassone.display_label.should == []
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
      @file_asset.add_file(@test_file, "content", @file_name)
      @file_asset.save
    end

    it "should raise an exception when an invalid object is a parameter" do
      expect {
        @testclassone.add_content_metadata("Randon object", "Randon ds")
      }.to raise_error("Content Metadata can only be derived from ActiveFedora::Base objects")
    end

    it "should add appropiate content metadata for valid object" do
      @test_object.add_content_metadata(@file_asset, "content").should == 0

      @test_object.contentMetadata.resource.size.should == 1

      @test_object.contentMetadata.sequence.first.should == "1"
      @test_object.contentMetadata.content_size.first.should == @test_file.size.to_s
      @test_object.contentMetadata.content_mime_type.first.should == "application/pdf"
      @test_object.contentMetadata.content_format.first.should == "pdf"
      @test_object.contentMetadata.resource_object_id.first.should == @file_asset.pid
      @test_object.contentMetadata.resource_ds_id.first.should == "content"
      @test_object.contentMetadata.resource.file.location.first.should == "http://hydra.hull.ac.uk/assets/#{@file_asset.pid}/content"
      @test_object.contentMetadata.resource.diss_service_def.first.should == "afmodel:FileAsset"
      @test_object.contentMetadata.resource.diss_service_method.first.should == "getContent"
      @test_object.contentMetadata.display_label.first.should == @file_name
      @test_object.contentMetadata.content_id.first.should == @file_name
      @test_object.contentMetadata.resource.file.file_id.first.should == @file_name
    end

    after(:all) do
      @file_asset.delete 
      @test_object.delete
    end

  end

end

