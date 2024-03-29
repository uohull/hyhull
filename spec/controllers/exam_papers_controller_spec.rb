# spec/controllers/uketd_object_controller_spec.rb
require 'spec_helper'

describe ExamPapersController do
  login_cat

  describe "initial_step" do
    it "should render the first stage new page" do
       get :initial_step
       assigns[:exam_paper].should be_kind_of ExamPaper
       response.should render_template("initial_step")
    end
  end

  describe "creating" do
    it "should render the create page" do
       get :new
       assigns[:exam_paper].should be_kind_of ExamPaper
       response.should render_template("new")
    end
    it "should render the crete page with valid params specified" do
      get :new, "exam_paper"=>{"department_name"=>"ICTD"}, "date"=>{"month"=>"07", "year"=>"2013"}
      exam_paper = assigns[:exam_paper]
      exam_paper.should be_kind_of ExamPaper

      exam_paper.department_name.should == "ICTD"
      exam_paper.date_issued.should == "2013-07"

      response.should render_template("new")
    end
    it "should support create requests" do
       post :create, :exam_paper=>{"department_name"=>"ICTD"}
       exam_paper = assigns[:exam_paper]
       exam_paper.department_name.should == "ICTD"
    end
  end

 describe "editing" do
    it "should support edit requests" do
       get :edit, :id=>"hull:3058"
       assigns[:exam_paper].should be_kind_of ExamPaper
       assigns[:exam_paper].pid.should == "hull:3058"
    end
    it "should support updating objects" do
       put :update, :id=>"hull:3058", :exam_paper=>{"department_name"=>"ICTD"}
       exam_paper = assigns[:exam_paper]
       exam_paper.department_name.should == "ICTD"
    end
  end

  describe "deleting" do
    before(:each) do
      exam_paper = ExamPaper.new(department_name: "ICTD", module_code: "12345", date_issued: "2009-09")
      # We need to add permissions so we can delete...
      exam_paper.rightsMetadata.update_permissions({"group"=>{"contentAccessTeam" => "edit"}})
      exam_paper.save
      @id = exam_paper.id
    end

    it "should support destroy requests" do
      delete :destroy, :id=>@id
      flash[:notice].should == "Examination paper #{@id} was successfully deleted."
    end
  end

end
