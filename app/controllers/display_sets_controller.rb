# app/controllers/display_sets_controller.rb
class DisplaySetsController < ApplicationController

  include Hyhull::Controller::ControllerBehaviour 

  def new
    @display_set = DisplaySet.new(:display_set_id => params[:display_set_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @display_set }
    end

  end

  def create 
    @display_set = DisplaySet.new(params[:display_set])
    @display_set.apply_depositor_metadata(current_user.username, current_user.email)

    respond_to do |format|
      if @display_set.save
        format.html { redirect_to(edit_display_set_path(@display_set), :notice => "Display set was successfully created as #{@display_set.id}") }
        format.json { render :json => @display_set, :status => :created, :location => @display_set }
      else
        format.html {
          #flash[:error] = "There has been problems creating this resource"
          render :action => "new"
        }
        format.json { render :json => @display_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @display_set = DisplaySet.find(params[:id])
  end

  def edit
    @display_set = DisplaySet.find(params[:id])
  end

  def update
    @display_set = DisplaySet.find(params[:id]) 
    @display_set.update_attributes(params[:display_set])

    respond_to do |format|
      if @display_set.save
        format.html { redirect_to(edit_display_set_path(@display_set), :notice => 'Display set was successfully updated.') }
        format.json { render :json => @display_set, :status => :created, :location => @display_set }
      else
        format.html { render "edit" }
      end
    end
  end

  def update_permissions
    @display_set = DisplaySet.find(params[:id])
    update_metadata

    respond_to do |format|
      if @display_set.save
        format.html { redirect_to(edit_display_set_path(@display_set), :notice => 'Display set was successfully updated.') }
        format.json { render :json => @display_set, :status => :created, :location => @display_set } 
      else
        format.html { render "edit" }
      end     
    end
  end

  def tree
  end

  private

  def update_metadata
    valid_attributes = merged_perm_params
    @display_set.permissions = valid_attributes
  end

  def merged_perm_params
    permission_params = visibility_permission_params(params[:visibility])

    #Merge permission_params with the params..
     group_params = {"permissions" => {"group" => params["display_set"]["permissions"]["group"].merge!(permission_params["group"])}} unless permission_params.nil?
     group_params.merge(params["display_set"])["permissions"]

  end

  def visibility_permission_params(visibility)
    # only set explicit permissions
    case visibility
    when "open"
      perms = {"group"=>{"public"=>"read", "staff"=>"none", "student"=>"none"}}
    when "uoh"
      perms = {"group"=>{"staff"=>"read", "student"=>"read", "public"=>"none"}}
    when "uoh_staff"
      perms = {"group"=>{"staff"=>"read", "student"=>"none", "public"=>"none"}}
    when "uoh_student"
      perms = {"group"=>{"staff"=>"none", "student"=>"read", "public"=>"none"}}
    when "restricted" 
      perms = {"group"=>{"staff"=>"none", "student"=>"none", "public"=>"none"}}
    end
  end

end