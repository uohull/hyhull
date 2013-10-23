# The original RolesController is defined in the Hydra Role Management gem
# This overrides to restrict to Hull behaviour.
class RolesController < ApplicationController
  include Hydra::RoleManagement::RolesBehavior
  include Hyhull::Controller::RolesControllerBehaviour

  # The following are overidden controller actions
  before_filter :disabled_action, only: [:new, :create, :update, :destroy]
  # check_role_type defined in Hyhull::Controller::RolesControllerBehaviour
  before_filter :check_role_type, only: [:show]

  # Customised for Hyhull. Hyhull has the notion of RoleTypes (hydra_roles, user_roles etc..)
  # We only want the viewing/editing of the Hyhull type roles.
  def index
  	# Only return the hyhull roles, ignore the rest
  	@roles = Role.hyhull_roles
  end

  private
  
  # At present we do not permit specific actions from RolesBehavior
  def disabled_action
    flash[:notice] = "This role action has been disabled."
    redirect_to root_url
  end

end