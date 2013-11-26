# spec/controllers/content_metadata_controller_spec.rb
require 'spec_helper'

describe ContentMetadataController do
  set_referer
  login_cat

  describe "editing" do
    it "should support edit requests" do
       get :edit, :id=>"hull:756"
       assigns[:content_metadata].should be_kind_of Hyhull::Datastream::ContentMetadata
       assigns[:content_metadata].pid.should == "hull:756"
    end
    it "should support updating objects" do
       subject { put :update, :id=>"hull:756", :content_metadata=>{"sequence"=>["1", "2", "3", "4"], "display_label"=>["Main content label changed", "Scenario 1 video", "Scenario 2 video", "Scenario 3 video"]} }
       response.code.should eq("200")
      end
    end

end
