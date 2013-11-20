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
      it "should not raise an error because we have included Hyhull::ModelMethods" do
         testclassone = ResourceWorkflowBehaviourTestClass.new
      end

      it "get_resource_state should return 'proto'" do
        testclassone = ResourceWorkflowBehaviourTestClass.new
        testclassone.get_resource_state.should == "proto"
        testclassone.queue.id.should == "hull:protoQueue"
      end
    end
  end

  describe "instance method" do
    before(:each) do
      @test_instance = ResourceWorkflowBehaviourTestClass.new
      @test_parent_id="hull:669"
      @test_queue_id="hull:QAQueue"
    end
    it "apo should return the appropiate apo" do
      # When queue_apo is set, apo should return that apo...
      @test_instance.queue_apo_id = @test_queue_id
      @test_instance.apo.id.should == @test_queue_id

      # When parent_apo is set, apo should that apo...
      @test_instance.queue_apo = nil
      @test_instance.parent_apo_id = @test_parent_id
      @test_instance.apo.id.should == @test_parent_id
    end
  end


  describe "apply_permissions" do
    before(:each) do
      @instance = ResourceWorkflowBehaviourTestClass.new
    end

    it "should be set to false by default" do
      @instance.apply_permissions.should be_false
    end

    it "should be set to true after a transition" do
      @instance.submit_resource
      @instance.apply_permissions.should be_true
    end

    it "should be set to true if the parent set changes on a published object" do
      @instance.resource_state = "published" 
      @instance.parent = StructuralSet.find("hull:rootSet")
      @instance.apo = StructuralSet.find("hull:rootSet")
      @instance.save 

      instance = ResourceWorkflowBehaviourTestClass.find(@instance.pid)

      # No changes to parent, so no changes to apo, so apply_permissions is false... 
      instance.set_apo 
      instance.apply_permissions.should be_false

      # A change to parent, so a change is required to apo, and apply_permissions should be true...
      instance.parent = StructuralSet.find("hull:657")
      instance.set_apo
      instance.apply_permissions.should be_true
    end


  end

  
  describe "ResourceWorkflowBehaviour" do

    before(:all) do
      @object = ResourceWorkflowBehaviourTestClass.create
      @test_parent_id="hull:669"
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
       it "should contain the apo getter" do
         defined?(@object.apo).should eq("method")
       end        
    end

    # Note these should be executed in order - rspec --order default
    describe "state_machine state" do
      context "proto" do
        it "should be the initial state for a new instance" do
          @object.resource_state.should == "proto"
          @object.queue.id.should == "hull:protoQueue"
          @object.queue_apo.should == nil
          @object.parent_apo.should == nil
          @object.apo.should == nil
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
          @object.save

          @object.resource_state.should == "qa"
          @object.queue.id.should == "hull:QAQueue"
          @object.queue_apo.id.should == "hull:QAQueue"
          @object.apo.id.should == "hull:QAQueue"
          @object.parent_apo.should == nil
          @object.relationships(:is_member_of).include?("info:fedora/hull:QAQueue").should be_true
        end

        it "should have the correct event transitions" do
          @object.resource_state_events.should include(:publish)
        end

      end

      context "publish" do  
        it "should be the state after calling publish_resource" do
          @object.publish_resource
          @object.save.should == false
          @object.errors.messages.should == {:parent=>["not assigned"]}

          @object = ResourceWorkflowBehaviourTestClass.find(@object.id)
          @object.parent_id = @test_parent_id
          @object.publish_resource

          @object.save.should == true
          @object.resource_state.should == "published"
          @object.queue.should == nil
          @object.queue_apo.should == nil
          @object.parent.id.should == @test_parent_id
          @object.parent_apo.id.should == @test_parent_id            
          @object.apo.id.should == @test_parent_id
          @object.relationships(:is_member_of).include?("info:fedora/hull:QAQueue").should be_false
          @object.relationships(:is_member_of).include?("info:fedora/hull:669").should be_true
        end
        
        it "should have the correct event transitions" do
          @object = ResourceWorkflowBehaviourTestClass.find(@object.id)
          @object.resource_state_events.should include(:delete, :hide)
        end
      end

      context "hidden" do
        it "should be the state after calling hide_resource" do

          @object = ResourceWorkflowBehaviourTestClass.find(@object.id)
          @object.hide_resource
          @object.save

          @object.resource_state.should == "hidden"
          @object.queue.id.should == "hull:hiddenQueue"
          @object.relationships(:is_member_of).include?("info:fedora/hull:hiddenQueue").should be_true
          #parent should remain referenced...
          @object.parent.id.should == @test_parent_id
          # apo should be switched back to the queue set
          @object.apo.id.should == "hull:hiddenQueue"
          @object.queue_apo.id.should == "hull:hiddenQueue"
          @object.parent_apo.should == nil

          # Test the inner fedora object state for hidden/deleted
          @object.inner_object.state.should == "D"
        end
        it "should have the correct transitions" do
          @object = ResourceWorkflowBehaviourTestClass.find(@object.id)
          @object.resource_state_events.should include(:delete, :submit)
        end  
      end
  
      context "deleted" do
        it "should not let me publish the resource before QA" do
           @object.publish_resource.should == false
        end
        it "should be the state after calling delete_resource" do
          @object = ResourceWorkflowBehaviourTestClass.find(@object.id)
          @object.delete_resource
          @object.save

          @object.resource_state.should == "deleted"
          @object.relationships(:is_member_of).include?("info:fedora/hull:deletedQueue").should be_true
          @object.queue.id.should == "hull:deletedQueue"

          #parent should remain referenced...
          @object.parent.id.should == @test_parent_id
          # apo should be switched back to the queue set
          @object.apo.id.should == "hull:deletedQueue"
          @object.queue_apo.id.should == "hull:deletedQueue"
          @object.parent_apo.should == nil
           # Test the inner fedora object state for hidden/deleted
          @object.inner_object.state.should == "D"
        end
        it "should have the correct transitions" do
          @object = ResourceWorkflowBehaviourTestClass.find(@object.id)
          @object.resource_state_events.should include(:submit)
        end
      end 

      context "submit after hidden/delete" do
        it "should change the fedora object state back to active" do
          @object = ResourceWorkflowBehaviourTestClass.find(@object.id)
          # Re-submit 
          @object.submit_resource
          @object.save

          @object.queue.id.should == "hull:QAQueue"
          @object.apo.id.should == "hull:QAQueue"
          @object.parent_apo.should == nil
          @object.queue_apo.id.should == "hull:QAQueue"
          @object.inner_object.state.should == "A"
        end
      end     

    end

    describe "persisted _resource_state" do
      before(:each) do
        @test_object = ResourceWorkflowBehaviourTestClass.new    
      end
      it "should reflect the correct state after save" do  
        @test_object.save 

        @test_object._resource_state.should == "proto"
        
        @test_object.submit_resource
        @test_object.save

        @test_object._resource_state.should == "qa"
      end
      after do
        @test_object.delete
      end
    end

    after(:all) do
      @object.delete
    end

  end

end
