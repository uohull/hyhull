# spec/controllers/content_metadata_controller_spec.rb
require 'spec_helper'

describe FilesController do
  login_cat

  describe "create" do
    before(:all) do
      @generic_parent = UketdObject.find("hull:756")
      @test_file = fixture("hyhull/files/test_pdf_file.pdf")
      @test_upload = ActionDispatch::Http::UploadedFile.new({ :filename => 'test_pdf_file.pdf', :type => 'application/pdf', :tempfile => @test_file })
    end

    it "should support file create post" do
      post :create, :container_id=>@generic_parent.pid, :Filedata => @test_upload
      flash[:notice].should == "The following files have been added sucessfully to hull:756: [\"test_pdf_file.pdf\"]"
    end
  end

  describe "destroy" do
    before(:all) do
      @generic_parent = UketdObject.find("hull:756")
      # The index of the last file asset of the object
      @index_of_file = @generic_parent.contentMetadata.resource.size - 1
      @id_of_asset = @generic_parent.contentMetadata.resource(@index_of_file).resource_object_id.first
    end

    it "should support file deletion" do
      delete :destroy, :id=>@id_of_asset, :container_id=>@generic_parent.pid, :index=>@index_of_file
      flash[:notice].should == "File test_pdf_file.pdf (#{@id_of_asset}) deleted sucessfully"
    end
  end

end