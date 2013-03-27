# spec/controllers/uketd_object_controller_spec.rb
require 'spec_helper'

describe UketdObjectsController do

  describe "creating" do
    it "should render the create page" do
       get :new
       assigns[uketd_object].should be_kind_of UketdObject
       renders.should == "new"
    end
    it "should support create requests" do
       post :create, :uketd_object=>{"title"=>"My title"}
       etd = assigns[:uketd_object]
       ja.title.should == "My title"
    end
  end

 describe "editing" do
    it "should support edit requests" do
       get :edit, :id=>"hull:756"
       assigns[:uketd_object].should be_kind_of UketdObject
       assigns[:uketd_object].pid.should == "hul:756"
    end
    it "should support updating objects" do
       put :update, :uketd_object=>{"title"=>"My Newest Title"}
       etd = assigns[:uketd_object]
       etd.title.should == "My Newest Title"
    end
  end

end