  # Allows you to use CanCan to control access to Models
  require 'cancan'
  class Ability
    include CanCan::Ability
    include Hydra::Ability
    include Hydra::PolicyAwareAbility

    # Overriden initialize to add admin ability for 'Role'
    def initialize(user, session=nil)
      super(user, session)

      if @current_user.admin?
        can [:create, :show, :add_user, :remove_user, :index], Role
      end
    end

  end