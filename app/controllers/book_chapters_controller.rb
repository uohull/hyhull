# app/controllers/book_chapters_controller.rb
class BookChaptersController < ApplicationController

  include Hyhull::Controller::ControllerBehaviour 

  def new
    @book_chapter = instance_of_resource(nil)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @book_chapter }
    end

  end

  def create 
    @book_chapter = instance_of_resource(params[:book_chapter])
    @book_chapter.apply_depositor_metadata(current_user.username, current_user.email)

    respond_to do |format|
      if @book_chapter.save
        format.html { redirect_to(edit_book_chapter_path(@book_chapter), :notice => "Book chapter was successfully created as #{@book_chapter.id}") }
        format.json { render :json => @book_chapter, :status => :created, :location => @book_chapter }
      else
        format.html {
          #flash[:error] = "There has been problems creating this resource"
          render :action => "new"
        }
        format.json { render :json => @book_chapter.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @book_chapter = resource_instance_by_id(params[:id])
  end

  def edit
    @book_chapter = resource_instance_by_id(params[:id])
  end

  def update
    @book_chapter = resource_instance_by_id(params[:id])

    @book_chapter.update_attributes(params[:book_chapter])

    respond_to do |format|
      if @book_chapter.save
        format.html { redirect_to(edit_book_chapter_path(@book_chapter), :notice => 'Book was successfully updated.') }
        format.json { render :json => @book_chapter, :status => :created, :location => @book_chapter }
      else
        format.html { render "edit" }
      end
    end

  end

  def destroy
    @book_chapter = resource_instance_by_id(params[:id])
    @book_chapter.delete

    respond_to do |format|
      format.html { redirect_to(root_url, :notice => "Book chapter #{params[:id]} was successfully deleted.") }
      format.json { render :json => @book_chapter, :status => :deleted }
    end

  end

  private

    def instance_of_resource(params)
      BookChapter.new(params)
    end 

    def resource_instance_by_id(id)
       BookChapter.find(id)
    end

end