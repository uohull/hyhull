module Hyhull::RoleMapperBehaviour
  extend ActiveSupport::Concern

  module ClassMethods

    def role_names
      Role.all.map { |role| role.name }
    end
    
    # 
    # @param user_or_uid either the User object or user id
    # If you pass in a nil User object (ie. user isn't logged in), or a uid that doesn't exist, it will return an empty array
    def roles(user_or_uid)
      roles = []

      if user_or_uid.kind_of?(String)
        user = Hydra::Ability.user_class.find_by_user_key(user_or_uid)
        user_id = user_or_uid
      elsif user_or_uid.kind_of?(Hydra::Ability.user_class) && user_or_uid.user_key   
        user = user_or_uid
        user_id = user.user_key
      end

      unless user.nil?
        roles = user.roles.map { |role| role.name }
      end

      return roles
    end
    
    def whois(r)
      users = []

      users_by_role = Role.find_by_name(r)

      unless users_by_role.nil?
        users = users_by_role.users.map { |user| user.username}
      end

      return users
    end

  end

end