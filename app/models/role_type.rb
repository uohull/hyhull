class RoleType < ActiveRecord::Base
  has_many :roles
  attr_accessible :name

  def self.user_role_type
    find_or_initialize_by_name("user") 
  end

  def self.hyhull_role_type
    find_or_initialize_by_name("hyhull") 
  end

  def self.department_ou_role_type
    find_or_initialize_by_name("department_ou") 
  end

  def self.faculty_code_role_type
    find_or_initialize_by_name("faculty_code") 
  end

end
