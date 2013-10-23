module Hyhull::Controller::RolesControllerBehaviour

  # check_role_type confirms that the RoleType is of hyhull_role_type before
  # proceeding to action.  
  def check_role_type
    unless hyhull_role_type? 
      flash[:alert] = "You are not permitted to view this role."
      redirect_to root_url
    end
  end

  def hyhull_role_type? 
    @role.role_type == RoleType.hyhull_role_type 
  end

end