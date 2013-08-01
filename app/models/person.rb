# This ActiveRecord class used to map to the 'People' table
# In hyhull production mode, People is a view on a person database table
# thus it is read only, used for Person lookups on email address and roles
class Person < ActiveRecord::Base
  attr_readonly :username, :given_name, :family_name, :email_address, :user_type, :department_ou, :faculty_code

  # Returns a person by there username
  def self.person_by_username(username)
    person = self.find_or_initialize_by_username(username)
    if person.persisted?
      return person
    else
     return NullPerson.new
    end
  end

end

# NullPerson (NullObjectPattern)
# If person can not be matched to authenticated user,
# use this NullPerson
class NullPerson
  def user_type
    "guest"
  end

  def department_ou 
    "no_department"
  end

  def faculty_code
    "no_faculty"
  end
  
  def email_address 
    "no email"
  end
end