class User < ActiveRecord::Base
 has_and_belongs_to_many :roles
# Connects this user object to Hydra behaviors. 
# At present Users 'hydra' roles will not change unless they are changed manually (via inteface/db). This means that even if the users user_type/department/faculty change, the hydra role will remain same. 

 include Hydra::User# Connects this user object to Role-management behaviors. 
 include Hydra::RoleManagement::UserRoles

# Connects this user object to Blacklights Bookmarks. 
 include Blacklight::User
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  #devise :cas_authenticatable, :trackable, :timeoutable
  devise :saml_authenticatable, :trackable, :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :remember_me, :username
  # attr_accessible :title, :body

  before_save :update_user_attributes

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account. 
  def to_s
    username
  end

  # Override Hydra::RoleManagement::UserRoles to return the groups plus combined_user_organisation_roles
  # Utilised to enable permissions to be targeted at department/faculity user type level..  
  def groups 
    combined_roles = get_combined_user_organisation_roles
    super().concat(combined_roles)   
  end 

  private

  # Updates the user attributes based upon the Person record (People table)
  # Person attributes utilised include - email_address, user_type, department_ou, and faculty_code 
  # user_type, department_ou, and faculty_code are used to create different roles for the user
  def update_user_attributes
    unless username.to_s.empty?
      person = Person.person_by_username(username)

      # Update the e-mail address if required... 
      self.email = person.email_address unless self.email == person.email_address

      # Roles generated from the Person fields, user/department/faculty roles are all 
      # different RoleTypes
      user_role = Role.match_user_role_by_name(person.user_type)
      department_role = Role.match_department_role_by_name(person.department_ou)
      faculty_role = Role.match_faculty_role_by_name(person.faculty_code)

      # Only update the role if it doesn't match the currently stored role.
      update_role(user_role) unless self.roles.include?(user_role)
      update_role(department_role) unless self.roles.include?(department_role)
      update_role(faculty_role) unless self.roles.include?(faculty_role)
    end
  end

  # Update the role
  # Roles of the same type 'department_ou' role will be deleted first 
  # and then the new role added.  
  def update_role(new_role)    
    self.roles.each do |role|
      self.roles.delete(role) if role.role_type == new_role.role_type
    end
    self.roles << new_role
  end

  # Returns a combined role of the user_type and the organisation (department_role/faculity_role)
  # example
  # User with "staff" user_role, "IT" department_ou_role and "123" faculty_code will return:-
  # ["IT_staff", "123_staff"]
  def get_combined_user_organisation_roles
    combined_roles = []

    user_role = role_of_type(RoleType.user_role_type)
    faculty_role = role_of_type(RoleType.faculty_code_role_type)
    department_role = role_of_type(RoleType.department_ou_role_type)

    combined_roles << "#{faculty_role.name}_#{user_role.name}" unless faculty_role.nil? 
    combined_roles << "#{department_role.name}_#{user_role.name}" unless department_role.nil? 

    return combined_roles
  end

  # Returns the role for a user based upon a type
  # role_type = RoleType
  def role_of_type(role_type)
    role_of_type = nil

    self.roles.each do |role| 
      role_of_type = role if (role.role_type == role_type)
    end

    return role_of_type
  end

end
