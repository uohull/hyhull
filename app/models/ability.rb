  # Allows you to use CanCan to control access to Models
  require 'cancan'
  class Ability
    include CanCan::Ability
    include Hydra::Ability
    include Hydra::PolicyAwareAbility

    def custom_permissions
      if @current_user.admin?
        # We are not adding update/delete to this on purpose for Roles
        can [:show, :add_user, :remove_user, :index], Role
      end
    end

  end