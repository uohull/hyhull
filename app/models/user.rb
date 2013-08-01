class User < ActiveRecord::Base
 has_and_belongs_to_many :roles
# Connects this user object to Hydra behaviors. 
 include Hydra::User# Connects this user object to Role-management behaviors. 
 include Hydra::RoleManagement::UserRoles

# Connects this user object to Blacklights Bookmarks. 
 include Blacklight::User
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :cas_authenticatable, :trackable

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

  # def groups
  #   RoleMapper.roles(user_key)
  # end

  private

  def update_user_attributes
    unless username.to_s.empty?
      person = Person.person_by_username(username)

      # Update the e-mail address if required... 
      self.email = person.email_address unless self.email == person.email_address

      user_role = Role.match_user_role_by_name(person.user_type)
      department_roles = Role.match_department_roles_by_names(person.department_ou_groups)
      faculty_roles = Role.match_faculty_roles_by_names(person.faculty_code_groups)

      add_user_role(user_role) unless self.roles.include?(user_role)
      # Add logic to check whether they need to be updated..
      add_department_roles(department_roles)
      add_faculty_roles(faculty_roles)
  end

  def add_user_role(role)
     user_role_type = RoleType.find_or_initialize_by_name("user")
     self.roles.delete_if {|role| role.role_type == user_role_type }
     self.roles << role
  end

  def add_department_roles(roles)
    department_role_type = RoleType.find_or_initialize_by_name("department_ou")
    self.roles.delete_if {|role| role.role_type == department_role_type }
    self.roles << roles 
  end

  def add_faculty_roles(roles)
    faculty_role_type = RoleType.find_or_initialize_by_name("faculty_code")
    self.roles.delete_if {|role| role.role_type == faculty_role_type }
    self.roles << roles 
  end

  def update_roles_users(person_roles)
    #If the role exists in the local database use it (staff/student/guest), otherwise turn to guest... 
    #Later throw exception, log, and set to guest... 
    if Role.find_or_initialize_by_name(user_type).persisted? then role =  Role.find_or_initialize_by_name(user_type) else role = Role.find_or_initialize_by_name("guest") end

  end

end
