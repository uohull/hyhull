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

#Seed the Roles data
["contentAccessTeam", "staff", "student", "committeeSection", "engineering", "guest", "admin", "contentCreator"].each {|r| Role.create(:name => r, :description => r) }