# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#hyhull Roles

#Clear existing roles
Role.delete_all
RoleType.delete_all
Person.delete_all unless Rails.env.production?

# Set role types..
# hyhull: hyhull application specific role types
# user: user role types generally 'staff/student/guest'
# department_ou/faculty_code
["hyhull", "user", "department_ou", "faculty_code"].each {|rt| RoleType.create(name: rt)}


# Seed the hyhull roles 
[{ name:"contentAccessTeam", description: "Content access team role"}, 
  { name:"contentCreator", description: "Content creator role"},
  { name: "admin", description: "Admin role" }
].each{ |r| Role.create(name: r[:name], description: r[:description], role_type: RoleType.find_or_initialize_by_name("hyhull")) }

# Seed the user roles
[{ name:"staff", description: "University staff role"},
 { name:"student", description: "University student role"},  
  { name:"guest", description: "University guest role"}
].each{ |r| Role.create(name: r[:name], description: r[:description], role_type: RoleType.find_or_initialize_by_name("user")) }


# Add a test records to people
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