# spec/controllers/dataset_controller_spec.rb
require 'spec_helper'

describe DatasetsController do
  login_cat

  describe "creating" do
    it "should render the create page" do
       get :new
       assigns[:dataset].should be_kind_of Dataset
       response.should render_template("new")
    end
    it "should support create requests" do
       post :create, :dataset=>{"title"=>"My title"}
       dataset = assigns[:dataset]
       dataset.title.should == "My title"
    end
  end

 describe "editing" do
    it "should support edit requests" do
       get :edit, :id=>"hull:2155"
       assigns[:dataset].should be_kind_of Dataset
       assigns[:dataset].pid.should == "hull:2155"
    end
    it "should support updating objects" do
       put :update, :id=>"hull:756", :dataset=>{"title"=>"My Newest Title"}
       dataset = assigns[:dataset]
       dataset.title.should == "My Newest Title"
    end
  end 

  describe "deleting" do
    before(:each) do
      dataset = Dataset.new(title: "Title")
      # We need to add permissions so we can delete...
      dataset.rightsMetadata.update_permissions({"group"=>{"contentAccessTeam" => "edit"}})
      dataset.save
      @id = dataset.id
    end

    it "should support destroy requests" do
      delete :destroy, :id=>@id
      flash[:notice].should == "Dataset #{@id} was successfully deleted."
    end
  end

end
