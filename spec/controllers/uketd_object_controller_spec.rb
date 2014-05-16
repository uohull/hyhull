# spec/controllers/uketd_object_controller_spec.rb
require 'spec_helper'
require 'user_helper'

describe UketdObjectsController do
  include UserHelper
	login_cat

  describe "creating" do
    it "should render the create page" do
       get :new
       assigns[:uketd_object].should be_kind_of UketdObject
       response.should render_template("new")
    end
    it "should support create requests" do
       post :create, :uketd_object=>{"title"=>"My title"}
       etd = assigns[:uketd_object]
       etd.title.should == "My title"
    end
    it "should NOT support create requests with custom pid_namespace specified" do
        post :create, :uketd_object=>{title: "A new piece of content", pid_namespace: "hull-archives", person_name: ["Bloggs Joe."], subject_topic: ["Test"], publisher: ["Uoh"], qualification_level: "Postgrad", qualification_name: "MSc", date_issued: "2009"}
        etd = assigns[:uketd_object]

        etd.pid.include?("changeme").should be_true
        etd.delete
    end
  end

 describe "editing" do
    it "should support edit requests" do
       get :edit, :id=>"hull:756"
       assigns[:uketd_object].should be_kind_of UketdObject
       assigns[:uketd_object].pid.should == "hull:756"
    end
    it "should support updating objects" do
       put :update, :id=>"hull:756", :uketd_object=>{"title"=>"My Newest Title"}
       etd = assigns[:uketd_object]
       etd.title.should == "My Newest Title"
    end
  end

  describe "deleting" do
    before(:each) do
      uketd_object = UketdObject.new(title: "A new piece of content", person_name: ["Bloggs Joe."], subject_topic: ["Test"], publisher: ["Uoh"], qualification_level: "Postgrad", qualification_name: "MSc", date_issued: "2009")
      # We need to add permissions so we can delete...
      uketd_object.rightsMetadata.update_permissions({"group"=>{"contentAccessTeam" => "edit"}})
      uketd_object.save
      @id = uketd_object.id
    end

    it "should support destroy requests" do
      delete :destroy, :id=>@id
      flash[:notice].should == "ETD #{@id} was successfully deleted."
    end
  end

  describe  "login_admin" do
    before(:each) do
      admin_user_sign_in
    end

    it "should support create requests with custom pid_namespace specified" do
      post :create, :uketd_object=>{title: "A new piece of content", pid_namespace: "hull-archives", person_name: ["Bloggs Joe."], subject_topic: ["Test"], publisher: ["Uoh"], qualification_level: "Postgrad", qualification_name: "MSc", date_issued: "2009"}
        
      uketd_object = assigns[:uketd_object]
      uketd_object.pid.include?("hull-archives").should be_true
      uketd_object.delete
    end
  end


end
