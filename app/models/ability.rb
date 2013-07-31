  # Allows you to use CanCan to control access to Models
  require 'cancan'
  class Ability
    include CanCan::Ability
    include Hydra::Ability
    include Hydra::PolicyAwareAbility

    def create_permissions
      # initial_step is a controller action on some resources for creation...
      can [:initial_step, :create], :all if user_groups.include? 'contentCreator'
    end

    def custom_permissions
      if @current_user.admin?
        # We are not adding update/delete to this on purpose for Roles
        can [:show, :add_user, :remove_user, :index], Role
      end
    end

  end
