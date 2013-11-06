# spec/controllers/roles_controller_spec.rb
require 'spec_helper'

describe RolesController do
  routes { Hydra::RoleManagement::Engine.routes }

  context "for authorised users" do
    login_admin

    describe "enabled actions" do
      it "index should return Roles" do
        get :index
        expect(response).to render_template("index")
      end

      it "show should return show page that enables the addition of users" do
        # As a test we get the first hyhull role id
        role_id = Role.hyhull_roles.first.id 
        get :show, id: role_id
        response.should render_template("show")
      end
    end

    # At present hyhull does not allow the creation of new roles, it only allows users to added to hyhull roles
    describe "disabled actions" do   
      it "new should redirect to root with a notice" do
        get :new
        flash[:notice].should == "This role action has been disabled."
        response.should redirect_to '/'
      end

      it "create should redirect to root with a notice" do
        post :create, :role=>{name: 'my_role'} 
        flash[:notice].should == "This role action has been disabled."
        response.should redirect_to '/'
      end
    end

    describe "CanCan::AccessDenied actions" do
      # Previously Controllers would raise CanCan::AccessDenied exception.
      # Now application_controller redirects CanCan::Access Denieds to root with an alert message
      it "update should redirect to root with a alert" do
         put :update, id: 1, :role=>{name: 'my_role'}
         flash[:alert].should == "You are not authorized to access this page."
         response.should redirect_to '/'
      end

      it "delete should redirect to root with a alert" do
         delete :destroy, id: 1
         flash[:alert].should == "You are not authorized to access this page."
         response.should redirect_to '/'
      end

      it "edit should redirect to root with a alert " do
        get :edit, id: 1
        flash[:alert].should == "You are not authorized to access this page."
        response.should redirect_to '/'
      end

    end    
    # No longer expect a raise_error - it redirects to root_url with alert - See above
    # describe "CanCan::AccessDenied actions" do
    #   # The following are actions that are controlled through the use of CanCan Abilities - See ability.rb
    #   it "update should raise an auth error" do        
    #     expect{put :update, id: 1, :role=>{name: 'my_role'}}.to raise_error(CanCan::AccessDenied)
    #   end

    #   it "destroy should raise an auth error" do
    #     expect{delete :destroy, id: 1}.to raise_error(CanCan::AccessDenied)
    #   end

    #   it "edit should raise an auth error" do
    #     expect{get :edit, id: 1}.to raise_error(CanCan::AccessDenied)
    #   end

    # end
  end

  context "for unauthorised users" do
    # Cat user does not have admin rights...
    login_cat

    describe "action" do
      it "index should redirect to root with alert" do
        get :index
        flash[:alert].should == "You are not authorized to access this page."
        response.should redirect_to '/'
      end

      it "show should redirect to root with alert" do
        # As a test we get the first hyhull role id
        role_id = Role.hyhull_roles.first.id
        get :show, id: role_id
        flash[:alert].should == "You are not authorized to access this page."
        response.should redirect_to '/'
      end
    end

  end

  
end