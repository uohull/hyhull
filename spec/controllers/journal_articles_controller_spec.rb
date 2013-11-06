# spec/controllers/uketd_object_controller_spec.rb
require 'spec_helper'

describe JournalArticlesController do
  login_cat

  describe "creating" do
    it "should render the create page" do
       get :new
       assigns[:journal_article].should be_kind_of JournalArticle
       response.should render_template("new")
    end
    it "should support create requests" do
       post :create, :journal_article=>{"title"=>"My title"}
       ja = assigns[:journal_article]
       ja.title.should == "My title"
    end
  end

 describe "editing" do
    it "should support edit requests" do
       get :edit, :id=>"hull:2376"
       assigns[:journal_article].should be_kind_of JournalArticle
       assigns[:journal_article].pid.should == "hull:2376"
    end
    it "should support updating objects" do
       put :update, :id=>"hull:2376", :journal_article=>{"title"=>"My Newest Title"}
       ja = assigns[:journal_article]
       ja.title.should == "My Newest Title"
    end
  end

  describe "deleting" do
    before(:each) do
      journal_article = JournalArticle.new(title: "A new piece of content", person_name: ["Bloggs Joe."], person_role_text: ["Author"], subject_topic: ["Test"], publisher: ["Uoh"])
      # We need to add permissions so we can delete...
      journal_article.rightsMetadata.update_permissions({"group"=>{"contentAccessTeam" => "edit"}})
      journal_article.save
      @id = journal_article.id
    end

    it "should support destroy requests" do
      delete :destroy, :id=>@id
      flash[:notice].should == "Journal article #{@id} was successfully deleted."
    end
  end

end