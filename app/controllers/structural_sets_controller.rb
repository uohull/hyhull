# app/controllers/structural_sets_controller.rb
class StructuralSetsController < ApplicationController

  include Hyhull::Controller::ControllerBehaviour 

  before_filter :validate_children_permissions, only: [:update_permissions]

  def new
    @structural_set = StructuralSet.new(:parent_id => params[:parent_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @structural_set }
    end

  end

  def create 
    @structural_set = StructuralSet.new(params[:structural_set])
    #@structural_set.apply_depositor_metadata(current_user.username, current_user.email)

    respond_to do |format|
      if @structural_set.save
        format.html { redirect_to(edit_structural_set_path(@structural_set), :notice => 'Structural set was successfully created.') }
        format.json { render :json => @structural_set, :status => :created, :location => @structural_set }
      else
        format.html {
          #flash[:error] = "There has been problems creating this resource"
          render :action => "new"
        }
        format.json { render :json => @structural_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @structural_set = StructuralSet.find(params[:id])
  end

  def edit
    @structural_set = StructuralSet.find(params[:id])
  end

  def update
    @structural_set = StructuralSet.find(params[:id]) 
    @structural_set.update_attributes(params[:structural_set])

    respond_to do |format|
      if @structural_set.save
        format.html { redirect_to(edit_structural_set_path(@structural_set), :notice => 'Structural set was successfully updated.') }
        format.json { render :json => @structural_set, :status => :created, :location => @structural_set }
      else
        format.html { render "edit" }
      end
    end
  end

  def update_permissions
    @structural_set = StructuralSet.find(params[:id])
    update_metadata

    respond_to do |format|
      if @structural_set.save
        format.html { redirect_to(edit_structural_set_path(@structural_set), :notice => 'Structural set was successfully updated.') }
        format.json { render :json => @structural_set, :status => :created, :location => @structural_set } 
      else
        format.html { render "edit" }
      end     
    end

  end


  private

  def validate_children_permissions

    unless params[:skip_warning] == "true"      
      structural_set = StructuralSet.find(params[:id])  

      # Check for skip_warning...      
      ancestors = structural_set.match_ancestors_default_object_rights
      non_matching_ancestors = ancestors[:dont_match]

      if non_matching_ancestors.size > 0
        id_list = ""
        ids = non_matching_ancestors.map{|resource| resource[:id] }
        ids.each {|id| id_list << "<li>#{id}</li>" }

        message = <<-EOS
                  <p>The following objects do not match the original rights metadata for this set:</p>
                  <ul>
                   #{id_list}
                  </ul>
                  <p>If you intend to proceed please select the appropiate rights again, and click <strong>Save</strong>.</p><br/>
                  <p><strong>Note:</strong> Non-matching sets permissions will not be changed, therefore its recommended that you print this page for your records.</p>          
                EOS

        flash[:notice] = message.html_safe
        redirect_to :controller=>"structural_sets", :action=>"edit", :id => structural_set.id, :warn => "true"
      end
    end

  end

  def update_metadata
    valid_attributes = merged_perm_params
    @structural_set.permissions = valid_attributes
  end

  def merged_perm_params
    permission_params = visibility_permission_params(params[:visibility])

    #Merge permission_params with the params..
     group_params = {"permissions" => {"group" => params["structural_set"]["permissions"]["group"].merge!(permission_params["group"])}} unless permission_params.nil?
     group_params.merge(params["structural_set"])["permissions"]

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