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

# Set role types..
# hyhull: hyhull application specific role types
# user: user role types generally 'staff/student/guest'
# department_ou/faculty_code
["hyhull", "user", "department_ou", "faculty_code"].each {|rt| RoleType.create(name: rt)}


# Seed the hyhull roles 
[{ name:"contentAccessTeam", description: "Content access team role"}, 
  { name:"contentCreator", description: "Content creator role"},
  { name: "admin", description: "Admin role" }
].each{ |r| Role.create(name: r[:name], description: r[:description], role_type: RoleType.where(name:"hyhull").first) }

# Seed the user roles
[{ name:"staff", description: "University staff role"},
 { name:"student", description: "University student role"},  
  { name:"guest", description: "University guest role"}
].each{ |r| Role.create(name: r[:name], description: r[:description], role_type: RoleType.where(name:"user").first) }

