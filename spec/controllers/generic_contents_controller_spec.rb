# spec/controllers/generic_contents_controller_spec.rb
require 'spec_helper'

describe GenericContentsController do
  login_cat

  describe "initial_step" do
    it "should render the first stage new page" do
       get :initial_step
       assigns[:generic_content].should be_kind_of GenericContent
       response.should render_template("initial_step")
    end
  end

  describe "creating" do
    it "should render the create page" do
       get :new
       assigns[:generic_content].should be_kind_of GenericContent
       response.should render_template("new")
    end
    it "should render the crete page with valid params specified" do
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

end