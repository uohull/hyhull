require 'spec_helper'

class ResourceWorkflowBehaviourTestClassThatWontWork < ActiveFedora::Base
  include Hyhull::ResourceWorkflowBehaviour
end

class ResourceWorkflowBehaviourTestClass < ActiveFedora::Base
  include Hyhull::ModelMethods
  include Hyhull::ResourceWorkflowBehaviour
end


describe Hyhull::ResourceWorkflowBehaviour do

  describe "instantiate" do
    context "invalid instance" do
      it "should raise an because we have not included Hyhull::ModelMethods" do
        expect {
          @testclassthatwontwork = ResourceWorkflowBehaviourTestClassThatWontWork.new
        }.to raise_error
      end
    end

    context "valid instance" do
      it "should not raise an because we have included Hyhull::ModelMethods" do
         testclassone = ResourceWorkflowBehaviourTestClass.new
      end

      it "get_resource_state should return 'proto'" do
        testclassone = ResourceWorkflowBehaviourTestClass.new
        testclassone.get_resource_state.should == "proto"
      end
    end
  end

  
  describe "ResourceWorkflowBehaviour" do

    before(:all) do
      @object = ResourceWorkflowBehaviourTestClass.new
    end

    describe "object instance" do     
       it "should contain the resource_state attribute" do
         defined?(@object.resource_state).should eq("method")
       end
       it "should contain the _resource_state delegated attribute" do
         defined?(@object._resource_state).should eq("method")
       end  
    end

    # Note these should be executed in order - rspec --order default
    describe "state_machine state" do
      context "proto" do
        it "should be the initial state for a new instance" do
          @object.resource_state.should == "proto"
        end
        it "should not let me publish the resource before QA" do
           @object.publish_resource.should == false
        end
        it "should have the correct event transitions" do
         @object.resource_state_events.should include(:submit)
        end        

      end

      context "qa" do
        it "should not let me call the delete event" do
          @object.delete_resource.should == false
        end
        it "should be the state after calling submit_resource" do
          @object.submit_resource
          @object.resource_state.should == "qa"
        end

        it "should have the correct event transitions" do
          @object.resource_state_events.should include(:publish)
        end

      end

      context "hidden" do
        it "should be the state after calling hide_resource" do
          @object.hide_resource
          @object.resource_state.should == "hidden"
        end
        it "should have the correct transitions" do
          @object.resource_state_events.should include(:delete, :submit)
        end  
      end
  
      context "deleted" do
        it "should not let me publish the resource before QA" do
           @object.publish_resource.should == false
        end
        it "should be the state after calling delete_resource" do
          @object.delete_resource
          @object.resource_state.should == "deleted"
        end
        it "should have the correct transitions" do
          @object.resource_state_events.should include(:submit)
        end
      end      

    end

    describe "persisted _resource_state" do
      it "should reflect the correct state after save" do
        object = ResourceWorkflowBehaviourTestClass.new        
        object.save 
        
        object._resource_state.should == "proto"
        
        object.submit_resource
        object.save

        object._resource_state.should == "qa"
      end      
    end
  end

end
