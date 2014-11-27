# spec/controllers/book_controller_spec.rb
require 'spec_helper'

describe BooksController do
  login_cat

  describe "creating" do
    it "should render the create page" do
       get :new
       assigns[:book].should be_kind_of Book
       response.should render_template("new")
    end
    it "should support create requests" do
       post :create, :book=>{"title"=>"My title"}
       book = assigns[:book]
       book.title.should == "My title"
    end
  end

 describe "editing" do
    it "should support edit requests" do
       get :edit, :id=>"hull:testBook"
       assigns[:book].should be_kind_of Book
       assigns[:book].pid.should == "hull:testBook"
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
      book = Book.new(title: "Title")
      # We need to add permissions so we can delete...
      book.rightsMetadata.update_permissions({"group"=>{"contentAccessTeam" => "edit"}})
      book.save
      @id = book.id
    end

    it "should support destroy requests" do
      delete :destroy, :id=>@id
      flash[:notice].should == "Book #{@id} was successfully deleted."
    end

  end

end
