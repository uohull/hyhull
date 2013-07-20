# spec/controllers/display_sets_controller_spec.rb
require 'spec_helper'

describe DisplaySetsController do
  login_cat

  describe "creating" do
    it "should render the create page" do
       get :new
       assigns[:display_set].should be_kind_of DisplaySet
       response.should render_template("new")
    end
    it "should support create requests" do
       post :create, :display_set=>{"title"=>"My title"}
       display_set = assigns[:display_set]
       display_set.title.should == "My title"
    end
  end

 describe "editing" do
    it "should support edit requests" do
       get :edit, :id=>"hull:domesdayDocumentation"
       assigns[:display_set].should be_kind_of DisplaySet
       assigns[:display_set].pid.should == "hull:domesdayDocumentation"
    end
    it "should support updating objects" do
       put :update, :id=>"hull:domesdayDocumentation", :display_set=>{"title"=>"Domesday dataset : documentation etc.."}
       display_set = assigns[:display_set]
       display_set.title.should == "Domesday dataset : documentation etc.."
    end
  end

  describe "permissions" do
    it "should support update objects" do
       put :update_permissions, :id=>"hull:657", :display_set=>{"permissions"=>{"group"=>{},"new_group_name"=>{"committeeSection"=>"read"}}}, :visibility=>"uoh_staff", :new_group_name_skel=>"committeeSection", :new_group_permission_skel=>"read"
       display_set = assigns[:display_set]
       display_set.permissions.should == [{:type=>"group", :access=>"read", :name=>"committeeSection"}, {:type=>"group", :access=>"read", :name=>"staff"},{:type=>"group", :access=>"edit", :name=>"contentAccessTeam"}]
    end
  
    describe "visibility_permission_params" do
      it "should return the appropiate permissions params for for the specified visiblity" do
        subject.send(:visibility_permission_params, "open").should == {"group"=>{"public"=>"read", "staff"=>"none", "student"=>"none"}}
        subject.send(:visibility_permission_params, "uoh").should == {"group"=>{"staff"=>"read", "student"=>"read", "public"=>"none"}}
        subject.send(:visibility_permission_params, "uoh_staff").should == {"group"=>{"staff"=>"read", "student"=>"none", "public"=>"none"}}
        subject.send(:visibility_permission_params, "uoh_student").should =={"group"=>{"staff"=>"none", "student"=>"read", "public"=>"none"}}
        subject.send(:visibility_permission_params, "restricted").should == {"group"=>{"staff"=>"none", "student"=>"none", "public"=>"none"}}
      end

    end

  end
end
