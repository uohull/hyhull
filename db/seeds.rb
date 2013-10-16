# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

#hyhull Roles
#Clear existing roles in dev/test mode only.. 
unless Rails.env.production?
  Role.delete_all 
  RoleType.delete_all 
  Person.delete_all
end

# Set role types - These are required for the Hyhull Application
# hyhull: hyhull application specific role types
# user: user role types generally 'staff/student/guest'
# department_ou/faculty_code
["hyhull", "user", "department_ou", "faculty_code"].each {|rt| RoleType.create(name: rt)}

# Seed the hyhull roles
# These are the required hyhull specific roles
[{ name:"contentAccessTeam", description: "Content access team role"}, 
  { name:"contentCreator", description: "Content creator role"},
  { name: "admin", description: "Admin role" }
].each{ |r| Role.create(name: r[:name], description: r[:description], role_type: RoleType.find_or_initialize_by_name("hyhull")) }

# Seed the user roles
# The standard list of user roles
[{ name:"staff", description: "University staff role"},
 { name:"student", description: "University student role"},  
  { name:"guest", description: "University guest role"}
].each{ |r| Role.create(name: r[:name], description: r[:description], role_type: RoleType.find_or_initialize_by_name("user")) }

# Seed the department roles
# We need to think about seeding the full list for production..
[{ name:"no_department", description: "No Department OU"} 
].each{ |r| Role.create(name: r[:name], description: r[:description], role_type: RoleType.find_or_initialize_by_name("department_ou")) }

# Seed the faculty roles
# We need to think about seeding the full list for production..
[{ name:"no_faculty", description: "No Faculty code"} 
].each{ |r| Role.create(name: r[:name], description: r[:description], role_type: RoleType.find_or_initialize_by_name("faculty_code")) }
  

# **************************** #
#  IMPORTANT - For Test #
# **************************** #
#                              #
# These get loaded in the database, and important for running the Tests
# Also loaded in development mode for extra test roles/users. 
unless Rails.env.production?
  # For test lets seed some made up departments and faculities (these need to exist in the Roles DB to be picked up on user login)

  # Seed the dep roles
  [{ name:"IT", description: "IT Department"},
  { name:"LLI", description: "LLI Department"},  
  { name:"CompSci", description: "Computer Science"}
  ].each{ |r| Role.create(name: r[:name], description: r[:description], role_type: RoleType.find_or_initialize_by_name("department_ou")) }

  # Seed the faculty roles
  [{ name:"123", description: "IT/LLI Faculty"},
  { name:"456", description: "Science and Engineering"} 
  ].each{ |r| Role.create(name: r[:name], description: r[:description], role_type: RoleType.find_or_initialize_by_name("faculty_code")) }

  # Seed some 'people' into the Person model, in production the Person model is populated from the Portal Person DB
  # These accounts are for test purposes only...
   [{ username: 'contentaccessteam1',  given_name: 'content', family_name: 'team', email_address: 'contentAccessTeam1@example.com', 
     user_type: 'contentAccessTeam', department_ou: 'IT', faculty_code: '123'},
     { username: 'staff1',  given_name: 'staff', family_name: 'user', email_address: 'staff1@example.com', 
     user_type: 'staff', department_ou: 'IT', faculty_code: '123'},
     { username: 'student1',  given_name: 'student', family_name: 'user', email_address: 'student1@example.com', 
     user_type: 'student', department_ou: 'CompSci', faculty_code: '456'},
     { username: 'archivist1',  given_name: 'archivist', family_name: 'user', email_address: 'archivist1@example.com', 
     user_type: 'archivist', department_ou: 'LLI', faculty_code: '123'},
     { username: 'bigwig',  given_name: 'bigwig', family_name: 'user', email_address: 'bigwig@example.com', 
     user_type: 'staff', department_ou: 'LLI', faculty_code: '123'}
     ].each do |p|
         person = Person.new
         person.username = p[:username]
         person.given_name = p[:given_name]
         person.family_name = p[:family_name]
         person.email_address = p[:email_address]
         person.user_type = p[:user_type]
         person.department_ou = p[:department_ou]
         person.faculty_code = p[:faculty_code]
         person.save
  end

end

# **************************** #
#  IMPORTANT - For Development #
# **************************** #
#                              #
# We will probably want to add entries to People and Roles(Departments/Faculties) that work with our development instance of CAS, i.e. users that can authenticate 
# I.e if we authenticate with the user 'test_admin_1' who has a department of test and faculty code of '001' we will add...
# ... a Person to the people table with a username of 'test_admin_1', and faculty_code of '001' and department_ou of 'test_dep'
# We would also need to add faculty and department to the Roles table for them to be recognised on login. See commented example below...
if Rails.env.development?

 # ******************************************************************************************
 # NOTE: The following is example of a Person you can add to People for development purposes

 # [{ username: 'test_admin_1',  given_name: 'Test', family_name: 'Admin', email_address: 'test_admin_1@example.com', 
 #     user_type: 'staff', department_ou: 'test_dep', faculty_code: '001'}].each do |p|
 #         person = Person.new
 #         person.username = p[:username]
 #         person.given_name = p[:given_name]
 #         person.family_name = p[:family_name]
 #         person.email_address = p[:email_address]
 #         person.user_type = p[:user_type]
 #         person.department_ou = p[:department_ou]
 #         person.faculty_code = p[:faculty_code]
 #         person.save
 #  end

 #  # NOTE: The following is example of the corresponding Department roles you will need to add to match the above Person
 #  [{ name:"test_dep", description: "Test Department"}].each do |r| 
 #    Role.create(name: r[:name], description: r[:description], role_type: RoleType.find_or_initialize_by_name("department_ou")) 
 #  end


 #  # NOTE: The following is example of the corresponding Faculty roles you will need to add to match the above Person
 #  [{ name:"001", description: "Test Faculty"}].each do |r|
 #    Role.create(name: r[:name], description: r[:description], role_type: RoleType.find_or_initialize_by_name("faculty_code"))
 #  end

end