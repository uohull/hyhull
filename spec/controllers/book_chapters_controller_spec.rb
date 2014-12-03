# spec/controllers/book_chapters_controller_spec.rb
require 'spec_helper'

describe BookChaptersController do
  login_cat

  describe "creating" do
    it "should render the create page" do
       get :new
       assigns[:book_chapter].should be_kind_of BookChapter
       response.should render_template("new")
    end
    it "should support create requests" do
       post :create, :book_chapter=>{"title"=>"My title"}
       book_chapter = assigns[:book_chapter]
       book_chapter.title.should == "My title"
    end
  end

 describe "editing" do
    it "should support edit requests" do
       get :edit, :id=>"hull:testBook"
       assigns[:book_chapter].should be_kind_of BookChapter
       assigns[:book_chapter].pid.should == "hull:testBook"
    end
    # Need to check this test - failing unsure why
    # it "should support updating objects" do
    #    put :update, :id=>"hull:testBook", :book=>{"title"=>"My Newest Title"}
    #    book = Book.find("hull:testBook")
    #    book.title.should == "My Newest Title"
    # end
  end 

  describe "deleting" do
    before(:each) do
      book_chapter = BookChapter.new(title: "Title")
      # We need to add permissions so we can delete...
      book_chapter.rightsMetadata.update_permissions({"group"=>{"contentAccessTeam" => "edit"}})
      book_chapter.save
      @id = book_chapter.id
    end

    it "should support destroy requests" do
      delete :destroy, :id=>@id
      flash[:notice].should == "Book chapter #{@id} was successfully deleted."
    end

  end

end
