# This ActiveRecord class is used to store the RoleType
# The Role types are... (defined in db/seeds.rb)
#  * user - A RoleType for Staff/Student/Guest type roles
#  * hyhull - A RoleType for Hyhull specific roles like 'contentCreator', 'contentAccessTeam'
#  * department_ou - A RoleType for Departments like 'it', 'lli'
#  * faculty_code - A RoleType for Faculties codes like '123', '432'
class RoleType < ActiveRecord::Base
  has_many :roles
  attr_accessible :name

  # User role_type is "user"
  def self.user_role_type
    find_or_initialize_by_name("user") 
  end

  # Hyhull role_type is "hyhull"
  def self.hyhull_role_type
    find_or_initialize_by_name("hyhull") 
  end

  # department_ou_role_type role_type is "department_ou"
  def self.department_ou_role_type
    find_or_initialize_by_name("department_ou") 
  end

  # faculty_code_role_type role_type is "faculty_code"
  def self.faculty_code_role_type
    find_or_initialize_by_name("faculty_code") 
  end

end
