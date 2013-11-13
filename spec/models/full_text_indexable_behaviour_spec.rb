require 'spec_helper'

class FullTextTestClass < ActiveFedora::Base
  include Hyhull::ModelMethods
  include Hyhull::GenericContentBehaviour
  include Hyhull::ContentMetadataBehaviour
  include Hyhull::FullTextIndexableBehaviour
  has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata
end

class FullTextTestGenericParentClass < ActiveFedora::Base
  include Hyhull::ModelMethods
  include Hyhull::GenericParentBehaviour
  include Hyhull::ContentMetadataBehaviour
  include Hyhull::FullTextIndexableBehaviour
  has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata
end

describe Hyhull::FullTextIndexableBehaviour do 

  context "with a GenericContent resource" do
    before(:each) do
      @test_generic_content = FullTextTestClass.create
      file1 = ActionDispatch::Http::UploadedFile.new({ :filename => 'test_pdf_file.pdf', :type => 'application/pdf', :tempfile => fixture("hyhull/files/test_pdf_file.pdf")})
      file2 = ActionDispatch::Http::UploadedFile.new({ :filename => 'test_content.pdf', :type => 'application/pdf', :tempfile =>  fixture("hyhull/files/test_content.pdf")})

      # Add the test file to the test fixture 
      @test_generic_content.add_file_content([file1])
      @test_generic_content.add_file_content([file2])
      @test_generic_content.save        
    end

    after(:each) do
      @test_generic_content.delete
    end

    describe ".primary_content_ds_and_object" do
      it "should return the reference to the primary datastream and object" do
        ds, object = @test_generic_content.primary_content_ds_and_object
        ds.should == @test_generic_content.datastreams["content"]
        object.should == @test_generic_content
      end
    end

    describe ".generate_full_text_datastream" do
      it "should return true" do
        @test_generic_content.generate_full_text_datastream.should == true
      end
    end

    describe ".full_text_datastream" do
      it "should be return a full text datastream after it has been generated" do
        @test_generic_content.full_text_datastream.should be_nil 
        @test_generic_content.generate_full_text_datastream 

        # It shouldn't be nil and it should have the correct text within it
        @test_generic_content.full_text_datastream.should_not be_nil
        @test_generic_content.full_text_datastream.content.should match(/This is a test PDF file/)
      end
    end

    describe ".to_solr" do
      it "should not return the field full_text_ti if text hasn't been extracted from the asset" do
        @test_generic_content.to_solr["full_text_ti"].should be_nil 
      end
      it "should return the field full_text_ti when text has been extracted from the asset" do
        # Generate the full text...
        @test_generic_content.generate_full_text_datastream
        # Then to_solr...
        @test_generic_content.to_solr["full_text_ti"].should_not be_nil 
      end
    end
  end


  context "with a GenericParent resource" do
    before(:each) do
      @test_generic_parent = FullTextTestGenericParentClass.create
      @test_generic_parent.apply_depositor_metadata("test", "test@test.com")

      file1 = ActionDispatch::Http::UploadedFile.new({ :filename => 'test_content.pdf', :type => 'application/pdf', :tempfile =>  fixture("hyhull/files/test_content.pdf")})
      file2 = ActionDispatch::Http::UploadedFile.new({ :filename => 'test_pdf_file.pdf', :type => 'application/pdf', :tempfile => fixture("hyhull/files/test_pdf_file.pdf")})

      # Add the test file to the test fixture 
      @test_generic_parent.add_file_content([file1])
      @test_generic_parent.add_file_content([file2])
      @test_generic_parent.save        
    end

    after(:each) do
      @test_generic_parent.delete
    end

    describe ".primary_content_ds_and_object" do
      it "should return the reference to the primary datastream and object" do
        ds, object = @test_generic_parent.primary_content_ds_and_object
        # The object should be first file asset and file asset content
        object.should == @test_generic_parent.file_assets.first
        ds.should == @test_generic_parent.file_assets.first.content
      end
    end

    describe ".generate_full_text_datastream" do
      it "should return true" do
        @test_generic_parent.generate_full_text_datastream.should == true
      end
    end

    describe ".full_text_datastream" do
      it "should be return a full text datastream after it has been generated" do
        @test_generic_parent.full_text_datastream.should be_nil 
        @test_generic_parent.generate_full_text_datastream 

        # It shouldn't be nil and it should have the correct text within it
        @test_generic_parent.full_text_datastream.should_not be_nil
        @test_generic_parent.full_text_datastream.content.should match(/This is a dummy thesis for demonstration purposes \n\n \n\nOption aperiri ei per, eos tale evertitur vituperatoribus ut, vim eius quaestio tractatos id./)
      end

      it "should exist within the FileAsset object being indexed" do
        @test_generic_parent.generate_full_text_datastream        
        # We return the resource labelled as seq 1 (the primary content datastream)
        content =  @test_generic_parent.get_resource_metadata_by_sequence_no("1")
        @test_generic_parent.full_text_datastream.pid.should == content[:asset_id]
      end
    end

    describe ".to_solr" do
      it "should not return the field full_text_ti if text hasn't been extracted from the asset" do
        @test_generic_parent.to_solr["full_text_ti"].should be_nil 
      end
      it "should return the field full_text_ti when text has been extracted from the asset" do
        # Generate the full text...
        @test_generic_parent.generate_full_text_datastream
        # Then to_solr...
        @test_generic_parent.to_solr["full_text_ti"].should_not be_nil 
      end
    end

  end 

end
