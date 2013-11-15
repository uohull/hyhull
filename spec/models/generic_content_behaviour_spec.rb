require 'spec_helper'

class GenericContentBehaviourTest < ActiveFedora::Base
  include Hyhull::GenericContentBehaviour

  def owner_id
    "fooAdmin"
  end

end

describe Hyhull::GenericContentBehaviour do

  context "with the GenericContentBehaviour" do
    before(:all) do
      @generic_content = GenericContentBehaviourTest.new
      @test_file = fixture("hyhull/files/test_pdf_file.pdf")
    end

    describe "FullTextDatastreamBehaviour" do
      it "should be included as part of the module" do
        @generic_content.class.ancestors.should include(Hyhull::FullTextDatastreamBehaviour)
      end
    end
  
    describe "GenericContentBehaviour#generate_ds_id" do    


      it "should return 'content' as the first available contentDs" do
        ds_id = @generic_content.generate_dsid("content")
        ds_id.should == "content"     

        new_ds_id = @generic_content.add_file_datastream(@test_file, {:label=>"Test", :prefix=>'content'})
        new_ds_id.should == "content"

        # lets make sure that the next one is content1
        ds_id = @generic_content.generate_dsid("content")
        ds_id.should == "content1"

        new_ds_id = @generic_content.add_file_datastream(@test_file, {:label=>"Test", :prefix=>'content'})
        new_ds_id.should == "content1"

        # lets make double sure that the next is content2...
        ds_id = @generic_content.generate_dsid("content")
        ds_id.should == "content2"

        new_ds_id = @generic_content.add_file_datastream(@test_file, {:label=>"Test", :prefix=>'content'})
        new_ds_id.should == "content2"
      end

    end
  end


  context "with the exam_paper hull:3058 test fixture" do
    describe "files" do
      before(:all) do
        @generic_content = ExamPaper.find("hull:3058")
        @test_file = fixture("hyhull/files/test_pdf_file.pdf")
        @ds = Hyhull::Datastream::ContentMetadata.from_xml(@cm)        
        @test_upload = ActionDispatch::Http::UploadedFile.new({ :filename => 'test_pdf_file.pdf', :type => 'application/pdf', :tempfile => @test_file })
      end

      it "should be add-able through the add_file_content(file_data) method" do
        content_metadata_resource_size = @generic_content.contentMetadata.resource.size
        content_datastreams_size = @generic_content.content_datastreams.size 

        success, file_assets, message = @generic_content.add_file_content([@test_upload])
        success.should == true
        message.should == "The following files have been added sucessfully to hull:3058: [\"test_pdf_file.pdf\"]"

        new_content_metadata_size = @generic_content.contentMetadata.resource.size
        resources_size = @generic_content.contentMetadata.resource.size

        new_content_metadata_size.should == (content_metadata_resource_size + 1)  
        # Check that the new ds and contentmetadata match up..
        file_ds_id = @generic_content.contentMetadata.resource(resources_size - 1).resource_ds_id[0]
        file_assets.first.should == file_ds_id

        @generic_content.content_datastreams.size.should == (content_datastreams_size + 1)
      end


      it "should be delete-able through the delete_by_content_metadata_at" do
        content_metadata = @generic_content.contentMetadata
        resources_size = content_metadata.resource.size

        file_asset_object_id = content_metadata.resource(resources_size - 1).resource_object_id[0]
        file_ds_id = content_metadata.resource(resources_size - 1).resource_ds_id[0]

        # A the file asset should be self in a generic content resource
        file_asset_object_id.should == @generic_content.id 

        # The content datastream should exist within the resource
        @generic_content.datastreams.include?(file_ds_id).should == true

        success, deleted_asset_ds_id, message = @generic_content.delete_by_content_metadata_resource_at(resources_size - 1)

        success.should == true        
        deleted_asset_ds_id.should == "#{file_asset_object_id}##{file_ds_id}"

        # Reload the resource from Fedora
        @generic_content = ExamPaper.find(@generic_content.id)

        #The resource should no longer include the deleted content ds... 
        @generic_content.datastreams.include?(file_ds_id).should == false
        content_metadata.resource.size.should == (resources_size - 1)

      end

    end
  end
end
