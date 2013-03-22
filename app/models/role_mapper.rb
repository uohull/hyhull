# RoleMapper This is used by AccessControlsEnforcement to get users' Roles (used in access permissions)
# If you are using something like Shibboleth or LDAP to get users' Roles, you should override this Class.  
# Your override should include a Module that implements the same behaviors as Hydra::RoleMapperBehavior
# Local overide #See Hyhull::RoleMapperBehavior
class RoleMapper
  include Hyhull::RoleMapperBehaviour
end