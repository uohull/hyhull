# spec/controllers/uketd_object_controller_spec.rb
require 'spec_helper'

class ResourceWorkflowBehaviourTestClass < ActiveFedora::Base
  include Hyhull::ModelMethods
  include Hyhull::ResourceWorkflowBehaviour
end

describe ResourceWorkflowController do
  set_referer
  login_cat  

  describe "updating" do   
    before(:each) do
      test = ResourceWorkflowBehaviourTestClass.new
      test.save
      @pid = test.pid 
    end

    context "valid update" do      
      it "should execute correctly for valid state submit transition" do
        put :update, :id=>@pid, :resource_state => "submit"
        flash[:notice].should == "Sucessfully added resource to the qa queue"
      end
    end

    context "invalid update" do
      it "should display the correct flash message for an invalid transition" do
        put :update, :id=>@pid, :resource_state => "purge"
        flash[:alert].should == "Problems executing the 'purge' transition on the resource"
      end
    end

  end
end

