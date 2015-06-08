# This ActiveRecord class is used to store the RoleType
# The Role types are... (defined in db/seeds.rb)
#  * user - A RoleType for Staf/Student/Guest type roles
#  * hyhull - A RoleType for Hyhull specific roles like 'contentCreator', 'contentAccessTeam'
#  * department_ou - A RoleType for Departments like 'it', 'lli'
#  * faculty_code - A RoleType for Faculties codes like '123', '432'
class RoleType < ActiveRecord::Base
  has_many :roles
  attr_accessible :name

  def self.user_role_type
    find_or_initialize_by_name(self.user_role_type_name) 
  end

  def self.staff_role_type
    find_or_initialize_by_name(self.staff_role_type_name) 
  end

  def self.hyhull_role_type
    find_or_initialize_by_name(self.hyhull_role_type_name) 
  end

  def self.department_ou_role_type
    find_or_initialize_by_name(self.department_ou_role_type_name) 
  end

  def self.faculty_code_role_type
    find_or_initialize_by_name(self.faculty_code_role_type_name) 
  end

  private
  #
  # *_role_type_name - these provide the textual name that these role_types are persisted as in the DB
  #  user_role name
  def self.user_role_type_name
    "user"
  end

  # hyhull_role name
  def self.hyhull_role_type_name
    "hyhull"
  end

  # department_ou name
  def self.department_ou_role_type_name
    "department_ou" 
  end

  # faculty_code name
  def self.faculty_code_role_type_name
    "faculty_code" 
  end

end
