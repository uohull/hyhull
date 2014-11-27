# app/controllers/book_controller.rb
class BooksController < ApplicationController

  include Hyhull::Controller::ControllerBehaviour 

  def new
    @book = instance_of_resource(nil)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @book }
    end

  end

  def create 
    @book = instance_of_resource(params[:book])
    @book.apply_depositor_metadata(current_user.username, current_user.email)

    respond_to do |format|
      if @book.save
        format.html { redirect_to(edit_book_path(@book), :notice => "Book was successfully created as #{@book.id}") }
        format.json { render :json => @book, :status => :created, :location => @book }
      else
        format.html {
          #flash[:error] = "There has been problems creating this resource"
          render :action => "new"
        }
        format.json { render :json => @book.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @book = resource_instance_by_id(params[:id])
  end

  def edit
    @book = resource_instance_by_id(params[:id])
  end

  def update
    @book = resource_instance_by_id(params[:id])

    @book.update_attributes(params[:book])

    respond_to do |format|
      if @book.save
        format.html { redirect_to(edit_book_path(@book), :notice => 'Book was successfully updated.') }
        format.json { render :json => @book, :status => :created, :location => @book }
      else
        format.html { render "edit" }
      end
    end

  end

  def destroy
    @book = resource_instance_by_id(params[:id])
    @book.delete

    respond_to do |format|
      format.html { redirect_to(root_url, :notice => "Book #{params[:id]} was successfully deleted.") }
      format.json { render :json => book, :status => :deleted }
    end

  end

  private

    def instance_of_resource(params)
      Book.new(params)
    end 

    def resource_instance_by_id(id)
       Book.find(id)
    end

end