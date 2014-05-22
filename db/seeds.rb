# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

#hyhull Roles
#Clear existing roles in dev/test mode only.. 
unless Rails.env.production?
  Role.delete_all 
  RoleType.delete_all 
  PropertyType.delete_all
  Property.delete_all
  User.delete_all
end

# Set role types - These are required for the Hyhull Application
# hyhull: hyhull application specific role types
# user: user role types generally 'staff/student/guest'
# department_ou/faculty_code
["hyhull", "user", "department_ou", "faculty_code"].each {|rt| RoleType.create(name: rt)}

# Seed the hyhull roles
# These are the required hyhull specific roles - See config/inintializers/hyhull.rb for the configuration of the roles
[{ name: HYHULL_USER_GROUPS[:content_access_team], description: "Content and Access Team"}, 
  { name: HYHULL_USER_GROUPS[:content_creator], description: "Content creator"},
  { name: HYHULL_USER_GROUPS[:administrator] , description: "Hyhull admininstrator" }
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
  
# Seed the PropertyType table
[ { name: "EXAM-PAPER-DEPARTMENT", description: "Examination paper department"},
  { name: "EXAM-PAPER-LEVEL", description: "Examination paper level"},
  { name: "ETD-QUALIFICATION-LEVEL", description: "ETD qualification level"},
  { name: "ETD-QUALIFICATION-NAME", description: "ETD qualification name"},
  { name: "ETD-DISSERTATION-CATEGORY", description: "ETD dissertation category"},
  { name: "FEDORA-PID-NAMESPACE", description: "Fedora PID namespace"}
].each { |p| PropertyType.create(name: p[:name], description: p[:description]) }


# Seed some default/test values in the Property table
unless Rails.env.production? 
  # EXAM-PAPER-DEPARTMENT
  ["Accounting and Finance","Business School","Centre for Lifelong Learning","Centre for Mathematics","Centre for Neuroscience",
    "Community/Rehabilitation Studies","Department of Chemistry",
    "Department of Computer Science"].each { |n| Property.create(name: n, value: n, property_type: PropertyType.where(name: "EXAM-PAPER-DEPARTMENT").first)}
  
  #EXAM-PAPER-LEVEL
  ["Level 4", "Level 5", "Level 6", "Level 7", "Level M", "Foundation level"].each { |n| Property.create(name: n, value: n, property_type: PropertyType.where(name: "EXAM-PAPER-LEVEL").first)}

  #ETD-QUALIFICATION-LEVEL
  ["Doctoral", "Masters", "Undergraduate"].each { |n| Property.create(name: n, value: n, property_type: PropertyType.where(name: "ETD-QUALIFICATION-LEVEL").first)}

  #ETD-QUALIFICATION-NAME
  ["PhD", "ClinPsyD", "MD", "PsyD", "MA" , "MEd", "MEng", "MPhil", "MRes",
    "MSc" , "MTheol", "EdD" , "DBA", "BA", "BSc"].each { |n| Property.create(name: n, value: n, property_type: PropertyType.where(name: "ETD-QUALIFICATION-NAME").first)}

  #ETD-DISSERTATION-CATEGORY
  ["Blue", "Green", "Red"].each { |n| Property.create(name: n, value: n, property_type: PropertyType.where(name: "ETD-DISSERTATION-CATEGORY").first)}

  #FEDORA-PID-NAMESPACE
  ["hull", "hull-archives"].each { |n| Property.create(name: n, value: n, property_type: PropertyType.where(name: "FEDORA-PID-NAMESPACE").first)}
end



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

end

# **************************** #
#  IMPORTANT - For Development #
# **************************** #
#                              #
# This code will seed the development database with users with various role types
# The users created have the following roles - contentAccessTeam (content management), contentCreator, Admin, staff role, student role 
#
if Rails.env.development?

  development_users = [
                        { email: 'cat@hyhull.com', password: 'cat123', password_confirmation: 'cat123' },
                        { email: 'creator@hyhull.com', password: 'creator123', password_confirmation: 'creator123' },
                        { email: 'admin@hyhull.com', password: 'admin123', password_confirmation: 'admin123' },
                        { email: 'staff@hyhull.com', password: 'staff123', password_confirmation: 'staff123' },
                        { email: 'student@hyhull.com', password: 'student123', password_confirmation: 'student123' }
                      ]

  # Create the dev users...
  development_users.each do |user|
    User.create(email: user[:email], password: user[:password], password_confirmation: user[:password_confirmation])
  end

  # Assign roles to the users..
  User.where(email: "cat@hyhull.com").first.roles << Role.where(name: "contentAccessTeam")
  User.where(email: "cat@hyhull.com").first.roles << Role.where(name: "staff")
   
  User.where(email: "creator@hyhull.com").first.roles << Role.where(name: "contentCreator")
  User.where(email: "cat@hyhull.com").first.roles << Role.where(name: "staff")
   
  User.where(email: "admin@hyhull.com").first.roles << Role.where(name: "admin")
  User.where(email: "admin@hyhull.com").first.roles << Role.where(name: "contentAccessTeam")
  User.where(email: "admin@hyhull.com").first.roles << Role.where(name: "staff")

  User.where(email: "staff@hyhull.com").first.roles << Role.where(name: "staff")
  User.where(email: "student@hyhull.com").first.roles << Role.where(name: "student")

end
