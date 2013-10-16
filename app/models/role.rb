# This ActiveRecord class is used to store the Roles
# Role includes the attributes: name, description, role_type
# Roles include hyhull application roles, user_type roles,
# department/faculty roles etc..
# All of these can be assigned to a user and used for permissions 
# based authorisation
class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  belongs_to :role_type

  attr_accessible :name, :description, :role_type

  validates :name, 
    uniqueness: true,
    format: { with: /\A[a-zA-Z0-9._-]+\z/,
      :message => "Only letters, numbers, hyphens, underscores and periods are allowed"}

  # Matches a user_role type
  # Returns an instance of Role based upon a string role_name 
  # If no match is found, guest is the default usertype role
  def self.match_user_role_by_name(role_name)
    role_record = self.match_role_by_name(role_name, RoleType.user_role_type)
    role_record.persisted? ? role_record : self.find_or_initialize_by_name_and_role_type_id(self.default_user_role, RoleType.user_role_type.id)
  end

  # Matches a department_role type
  # Returns an instance of Role based upon a string role_name
  # If no match is found, no_department is the default usertype role  
  def self.match_department_role_by_name(role_name)
    role_record = self.match_role_by_name(role_name, RoleType.department_ou_role_type)
    role_record.persisted? ? role_record : self.find_or_initialize_by_name_and_role_type_id(self.default_department_role, RoleType.department_ou_role_type.id)
  end

  # Matches a faculty_role type
  # Returns an instance of Role based upon a string role_name
  # If no match is  found, no_faculty is the default usertype role    
  def self.match_faculty_role_by_name(role_name)
    role_record = self.match_role_by_name(role_name, RoleType.faculty_code_role_type)
    role_record.persisted? ? role_record : self.find_or_initialize_by_name_and_role_type_id(self.default_faculty_role, RoleType.faculty_code_role_type.id)
  end

  private

  # Returns an instance of Role based upon role_name and role_type
  def self.match_role_by_name(role_name, role_type)
    role_record = self.find_or_initialize_by_name_and_role_type_id(role_name, role_type.id)
  end 

  # Default role used for user_type RoleTypes 
  def self.default_user_role
    "guest"
  end

  # Default role used for department_role RoleTypes 
  def self.default_department_role
    "no_department"
  end

  # Default role used for faculty_role RoleTypes 
  def self.default_faculty_role
    "no_faculty"
  end

end
