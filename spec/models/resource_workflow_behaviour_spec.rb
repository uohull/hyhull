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
      @object = ResourceWorkflowBehaviourTestClass.create
    end

    describe "associate rels-ext queues" do
      it "should be available for the appropiate resource states" do
        HYHULL_QUEUES.invert[:proto].should == "hull:protoQueue"
        HYHULL_QUEUES.invert[:qa].should == "hull:QAQueue"
        HYHULL_QUEUES.invert[:hidden].should == "hull:hiddenQueue"
        HYHULL_QUEUES.invert[:deleted].should == "hull:deletedQueue" 
      end
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
          @object.relationships(:is_member_of).include?("info:fedora/hull:protoQueue").should be_true
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
          @object.relationships(:is_member_of).include?("info:fedora/hull:QAQueue").should be_true
        end

        it "should have the correct event transitions" do
          @object.resource_state_events.should include(:publish)
        end

      end

      context "publish" do
        it "should be the state after calling publish_resource" do
          @object.publish_resource
          @object.resource_state.should == "published"
          @object.relationships(:is_member_of).include?("info:fedora/hull:QAQueue").should be_false
        end

        it "should have the correct event transitions" do
          @object.resource_state_events.should include(:delete, :hide)
        end

      end

      context "hidden" do
        it "should be the state after calling hide_resource" do
          @object.hide_resource
          @object.resource_state.should == "hidden"
          @object.relationships(:is_member_of).include?("info:fedora/hull:hiddenQueue").should be_true
          # Test the inner fedora object state for hidden/deleted
          @object.inner_object.state.should == "D"
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
          @object.relationships(:is_member_of).include?("info:fedora/hull:deletedQueue").should be_true
           # Test the inner fedora object state for hidden/deleted
          @object.inner_object.state.should == "D"
        end
        it "should have the correct transitions" do
          @object.resource_state_events.should include(:submit)
        end
      end 

      context "submit after hidden/delete" do
        it "should change the fedora object state back to active" do
          # Re-submit 
          @object.submit_resource
          @object.inner_object.state.should == "A"
        end
      end     

    end

    describe "persisted _resource_state" do
      it "should reflect the correct state after save" do
        test_object = ResourceWorkflowBehaviourTestClass.new        
        test_object.save 

        test_object._resource_state.should == "proto"
        
        test_object.submit_resource
        test_object.save

        test_object._resource_state.should == "qa"
      end      
    end
  end

end
