class UserRolesController < ApplicationController
  include Hydra::RoleManagement::UserRolesBehavior
  include Hyhull::Controller::RolesControllerBehaviour
  
  # check_role_type defined in Hyhull::Controller::RolesControllerBehaviour
  before_filter :check_role_type
end