# spec/controllers/generic_contents_controller_spec.rb
require 'spec_helper'
require 'user_helper'

describe GenericContentsController do
  include UserHelper

  login_cat

  describe "initial_step" do
    it "should render the first stage new page" do
       get :initial_step
       assigns[:generic_content].should be_kind_of GenericContent
       response.should render_template("initial_step")
    end
  end

  describe "creating" do

    describe "login_cat" do
      it "should render the create page" do
         get :new
         assigns[:generic_content].should be_kind_of GenericContent
         response.should render_template("new")
      end
      it "should render the create page with valid params specified" do
        get :new, "generic_content"=>{"genre"=>"Presentation"}
        generic_content = assigns[:generic_content]
        generic_content.should be_kind_of GenericContent

        generic_content.genre.should == "Presentation"
        response.should render_template("new")
      end
      it "should support create requests" do
         post :create, :generic_content=>{"title"=>"A Generic title"}
         generic_content = assigns[:generic_content]
         generic_content.title.should == "A Generic title"
      end

      it "should NOT support create requests with custom pid_namespace specified" do
        post :create, :generic_content=>{"title"=>"A Generic title", "genre" => "Book", "pid_namespace"=>"hull-archives"}
        generic_content = assigns[:generic_content]
        generic_content.pid.include?("changeme").should be_true
        generic_content.delete
      end
    end

    describe  "login_admin" do
      before(:each) do
        admin_user_sign_in
      end

      it "should support create requests with custom pid_namespace specified" do
        post :create, :generic_content=>{"title"=>"A Generic title", "genre" => "Book", "pid_namespace"=>"hull-archives"}
        generic_content = assigns[:generic_content]
        generic_content.pid.include?("hull-archives").should be_true
        generic_content.delete
      end

    end

  end

 describe "editing" do
    it "should support edit requests" do
       get :edit, :id=>"hull:2106"
       assigns[:generic_content].should be_kind_of GenericContent
       assigns[:generic_content].pid.should == "hull:2106"
    end
    it "should support updating objects" do
       put :update, :id=>"hull:2106", :generic_content=>{"title"=>"A new title"}
       generic_content = assigns[:generic_content]
       generic_content.title.should == "A new title"
    end
  end

  describe "deleting" do
    before(:each) do
      generic_content = GenericContent.new(title: "A new piece of content", genre: "Artwork")
      # We need to add permissions so we can delete...
      generic_content.rightsMetadata.update_permissions({"group"=>{"contentAccessTeam" => "edit"}})
      generic_content.save
      @id = generic_content.id
    end

    it "should support destroy requests" do
      delete :destroy, :id=>@id
      flash[:notice].should == "Resource #{@id} was successfully deleted."
    end
  end

end