# app/controllers/generic_content_controller.rb
class GenericContentsController < ApplicationController
  include Hyhull::Controller::ControllerBehaviour 
 
  def initial_step
    @generic_content = GenericContent.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @generic_content }
    end
  end

  def new
    @generic_content = GenericContent.new(params[:generic_content])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @generic_content }
    end

  end

  def create
    #If admin user, on create the namespace of the object will be defined by the pid_namespace attribute 
    if current_user.admin?
      @generic_content =  GenericContent.new(params[:generic_content].merge({ namespace: params[:generic_content][:pid_namespace]}))
    else
      # Other users cannot define the pidnamespace therefore Fedora default will be used (we ensure it isn't set by using nil)...
      @generic_content = GenericContent.new(params[:generic_content].merge({ namespace: nil }))
    end

    @generic_content.apply_depositor_metadata(current_user.username, current_user.email)

    respond_to do |format|
      if @generic_content.save
        genre = @generic_content.genre
        format.html { redirect_to(edit_generic_content_path(@generic_content), :notice => "#{genre} was successfully created as #{@generic_content.id}") }
        format.json { render :json => @generic_content, :status => :created, :location => @generic_content }
      else
        format.html {
          #flash[:error] = "There has been problems creating this resource"
          render :action => "new"
        }
        format.json { render :json => @generic_content.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @generic_content = GenericContent.find(params[:id])
  end

  def edit
    @generic_content = GenericContent.find(params[:id])
  end

  def update
    @generic_content = GenericContent.find(params[:id])

    @generic_content.update_attributes(params[:generic_content])

    respond_to do |format|
      if @generic_content.save
        genre = @generic_content.genre
        format.html { redirect_to(edit_generic_content_path(@generic_content), :notice => "#{genre} was successfully updated.") }
        format.json { render :json => @generic_content, :status => :created, :location => @generic_content }
      else
        format.html { render "edit" }
      end
    end
  end

  def destroy
    generic_content = GenericContent.find(params[:id])
    generic_content.delete

    respond_to do |format|
      format.html { redirect_to(root_url, :notice => "Resource #{params[:id]} was successfully deleted.") }
      format.json { render :json => generic_content, :status => :deleted }
    end

  end

end