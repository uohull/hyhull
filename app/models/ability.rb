  # Allows you to use CanCan to control access to Models
  # Hydra::Ability will handle the invidual rights for edit/updates of Resources based upon rightsMetadata
  require 'cancan'
  class Ability
    include CanCan::Ability
    include Hydra::Ability
    # We are not currently using the Hydra::PolicyAwareAbility (all our objects rightsMetadata reflect defaultObjectRights) - we can easily migrate to this in future given our usage of isGovernedBy 
    # include Hydra::PolicyAwareAbility

    def create_permissions
      # initial_step is a controller action on some resources for creation...
      if user_groups.include?(HYHULL_USER_GROUPS[:content_creator]) || 
          user_groups.include?(HYHULL_USER_GROUPS[:content_access_team]) || 
          @current_user.admin?
        can [:initial_step, :create], :all
      end

    end

    # Custom Hyhull Permissions 
    def custom_permissions 
      # hyhull Deletable abilities       
      # We cannot destroy an resource...
      cannot [:destroy], ActiveFedora::Base do |obj|
        # .. if it is not deletable 
        !deletable(obj)
      end

      # Structural and Display Set Browse and update_permissions - ContentAccessTeam and Admin
      if user_groups.include?(HYHULL_USER_GROUPS[:content_access_team]) || @current_user.admin?
        can [:tree, :update_permissions], StructuralSet 
        can [:tree, :update_permissions], DisplaySet
      end

      if user_groups.include?(HYHULL_USER_GROUPS[:yif_group])
        #see yifQueue
        #can [:initial_step, :create], JournalArticle
        #can [:initial_step, :create], :all
        can [:tree, :update_permissions], StructuralSet 
        can [:tree, :update_permissions], DisplaySet
        #can [:show, :add_user, :remove_user, :index], Role
        #can :read, PropertyType 
        #can :manage, Property 
      end

      if user_groups.include?(STAFF_USER_GROUPS[:staff])
        can [:initial_step, :create], JournalArticle
      end

      # Adminstration forms
      #
      # Role Management
      # We are not adding update/delete to this on purpose for Roles
      can [:show, :add_user, :remove_user, :index], Role if @current_user.admin?
      #
      # Properties Management - PropertyType and Property objects
      can :read, PropertyType if @current_user.admin?
      can :manage, Property if @current_user.admin?

    end

    private

    # Deletable based upon the Resource workflow state
    # In hyhull we have overridden the permissions of ActiveFedora::Based so that it's not just based upon whether the user is an editor.
    # Resources can only be deleted when their resource_state is proto, qa or deleted.  Resources in other state CANNOT be deleted    
    def deletable(obj)
      result = false

      # If the obj includes the Hyhull::ResourceWorkflowBehaviour then we will test which state is in...
      if obj.class.included_modules.include? Hyhull::ResourceWorkflowBehaviour 
        # At present Resources are ONLY deletable when in the PROTO, QA and DELETE state
        if obj.resource_proto? || obj.resource_qa? || obj.resource_deleted? #|| obj.resource_yif?
          result = true
        end
      else
        # We return true here, because we don't want to hijack the edit permissions of a resource that doesn't use Hyhull::ResourceWorkflowBehaviour 
        result = true
      end
      return result
    end

  end