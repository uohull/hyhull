class Person < ActiveRecord::Base
  attr_readonly :username, :given_name, :family_name, :email_address, :user_type, :department_ou, :faculty_code

  def self.person_by_username(username)
   return self.where(username: username).first || NullPerson.new
  end

  def department_ou_groups
    department_ou_groups = []
    department_ou_groups << department_ou unless department_ou.to_s.empty?
    department_ou_groups << combined_groups_string(department_ou, user_type) unless department_ou.to_s.empty? || user_type.to_s.empty? 
  end

  def faculty_code_groups
    faculty_code_groups = []
    faculty_code_groups << faculty_code unless faculty_code.to_s.empty?
    faculty_code_groups << combined_groups_string(faculty_code, user_type) unless faculty_code.to_s.empty? || user_type.to_s.empty? 
  end


  private

  def combined_groups_string(group1="", group2="")
    "#{group1}_#{group2}"
  end
end

# NullPerson (NullObjectPattern)
class NullPerson
  def user_type
    "guest"
  end

  def department_ou_groups 
    []
  end

  def faculty_code_groups
    []
  end
  
  def email_address 
    "no email"
  end

end