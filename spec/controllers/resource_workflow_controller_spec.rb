# spec/controllers/uketd_object_controller_spec.rb
require 'spec_helper'
require 'user_helper'


#Test OM Datastream
class TestOmDatastream < ActiveFedora::OmDatastream
  set_terminology do |t|
    t.root(:path=>"fields")
    t.mandatory_field_for_submit_transition
  end

  # Generates an empty contentMetadata
  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.fields {}
    end
    return builder.doc
  end
end

class ResourceWorkflowControllerTestClass < ActiveFedora::Base
  include Hydra::ModelMethods
  include Hyhull::ModelMethods
  include Hyhull::ResourceWorkflowBehaviour

  # Extra validations for the resource_state state changes
  ResourceWorkflowControllerTestClass.state_machine :resource_state do   
    state :qa do
      validates :mandatory_field_for_submit_transition, presence: true
    end
  end

  has_metadata :name => "test_ds", :label=>"test_ds", type: TestOmDatastream
  has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata
  has_attributes :mandatory_field_for_submit_transition, datastream: :test_ds, multiple: false

end


describe ResourceWorkflowController do
  include UserHelper

  set_referer
  login_cat  

  describe "updating" do   
    before(:each) do
      cat_user_sign_in
      @test = ResourceWorkflowControllerTestClass.new
      @test.apply_depositor_metadata(@user.username, @user.email)
      @test.save
      @pid = @test.pid 
    end

    context "valid update" do     
      it "should execute correctly for valid state submit transition" do
        @test.mandatory_field_for_submit_transition = "This has been populated"
        @test.save
        put :update, :id=>@pid, :resource_state => "submit"
        flash[:notice].should == "Sucessfully added resource #{@pid} to the qa queue"
      end

      it "should redirect to the homepage when the transition removes the users edit permissions" do
        @test.mandatory_field_for_submit_transition = "This has been populated"
        @test.submit_resource!
        @test.hide_resource! 
        # Resource is now in hidden queue...
        @test.save

        put :update, :id=>@pid, :resource_state => "delete" 
        response.should redirect_to root_path
        flash[:notice].should == "Sucessfully added resource #{@pid} to the deleted queue"
      end

    end
    context "invalid update" do
      it "should display the correct flash message for an invalid transition" do
        put :update, :id=>@pid, :resource_state => "purge"
        flash[:alert].should == "Problems executing the 'purge' transition on the resource"
      end
      
      it "should display the correct flash message for a transition that fails validation" do
        put :update, :id=>@pid, :resource_state => "submit"
        flash[:alert].should == "Problems saving the resource to the submit queue...</br></br>Mandatory field for submit transition can't be blank" 
      end

    end

    after do
      @test.delete
    end

  end
end

