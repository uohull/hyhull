class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  belongs_to :role_type

  attr_accessible :name, :description, :role_type

  validates :name, 
    uniqueness: true,
    format: { with: /\A[a-zA-Z0-9._-]+\z/,
      :message => "Only letters, numbers, hyphens, underscores and periods are allowed"}


  def self.match_user_role_by_name(role_name)
    role_record = self.find_or_initialize_by_name_and_role_type_id(role_name, RoleType.user_role_type.id)
    role_record.persisted? ? role_record : self.find_or_initialize_by_name_and_role_type_id(self.default_role, RoleType.user_role_type.id)
  end

  def self.match_department_roles_by_names(role_names)
  	self.match_roles_by_names(role_names, RoleType.department_ou_role_type) 
  end

  def self.match_faculty_roles_by_names(role_names)
  	self.match_roles_by_names(role_names, RoleType.faculty_code_role_type) 
  end

  private 

  def self.match_roles_by_names(role_names, role_type)
  	roles = []
  	unless role_names.empty?
      role_names.each do |role_name|
        role_record = self.find_or_initialize_by_name_and_role_type_id(role_name, role_type.id )     
        roles << role_record if role_record.persisted?	
      end
  	end
  	return roles
  end

  def self.default_role
    "guest"
  end

end
