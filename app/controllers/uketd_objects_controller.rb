# app/controllers/uketd_objects_controller.rb
class UketdObjectsController < ApplicationController

	include Hyhull::Controller::ControllerBehaviour 

	def new
		@uketd_object = UketdObject.new

		respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @uketd_object }
    end

	end

	def create
    # If admin user, on create the namespace of the object will be defined by the pid_namespace attribute 
    if current_user.admin?
      @uketd_object = UketdObject.new(params[:uketd_object].merge({ namespace: params[:uketd_object][:pid_namespace]}))
    else
      # Other users cannot define the pidnamespace therefore Fedora default will be used (we ensure it isn't set by using nil)...
      @uketd_object = UketdObject.new(params[:uketd_object].merge({ namespace: nil}))
    end

		@uketd_object.apply_depositor_metadata(current_user.username, current_user.email)

		respond_to do |format|
			if @uketd_object.save
				format.html { redirect_to(edit_uketd_object_path(@uketd_object), :notice => "ETD was successfully created as #{@uketd_object.id}") }
        format.json { render :json => @uketd_object, :status => :created, :location => @uketd_object }
      else
     		format.html {
     			#flash[:error] = "There has been problems creating this resource"
     			render :action => "new"
     		}
     		format.json { render :json => @uketd_object.errors, :status => :unprocessable_entity }
      end
		end
	end

	def show
    @uketd_object = UketdObject.find(params[:id])
  end

	def edit
    @uketd_object = UketdObject.find(params[:id])
  end

  def update
		@uketd_object = UketdObject.find(params[:id])

		@uketd_object.update_attributes(params[:uketd_object])

	  respond_to do |format|
			if @uketd_object.save
				format.html { redirect_to(edit_uketd_object_path(@uketd_object), :notice => 'ETD was successfully updated.') }
				format.json { render :json => @uketd_object, :status => :created, :location => @uketd_object }
			else
        format.html { render "edit" }
				#format.html { redirect_to(edit_uketd_object_path(@uketd_object, :alert => @uketd_object.errors.messages.values.to_s)) }
			end
		end
  end

  def destroy
    uketd_object = UketdObject.find(params[:id])
    # Calls by implicate the GenericParent variant of Delete
    uketd_object.delete

    respond_to do |format|
      format.html { redirect_to(root_url, :notice => "ETD #{params[:id]} was successfully deleted.") }
      format.json { render :json => uketd_object, :status => :deleted }
    end

  end


end