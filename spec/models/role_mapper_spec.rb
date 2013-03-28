require 'spec_helper'
require 'user_helper'

describe RoleMapper do
  include UserHelper

  before (:all) do

    #Load the roles
    load_roles

    #create a test cat user
    @cat_user = User.create!(:username => "contentAccessTeam1", :email => "contentAccessTeam1@example.com")
    @cat_user.roles = [Role.find_or_initialize_by_name("contentAccessTeam")]

    #create a test cat user
    @staff_user = User.create!(:username => "staff1", :email => "staff1@example.com")
    @staff_user.roles = [Role.find_or_initialize_by_name("staff")]

  end

 it "should define the 7 roles" do  
   RoleMapper.role_names.sort.should == %w(committeeSection contentAccessTeam contentCreator engineering guest staff student) 
 end

 it "should queryable for roles for a given user" do
   RoleMapper.roles('contentaccessteam1').should == ['contentAccessTeam']
 end

 it "should return an empty array if there are no roles" do
   RoleMapper.roles('Marduk,_the sun_god@example.com').empty?.should == true
 end
 it "should know who is what" do
   RoleMapper.whois('contentAccessTeam').sort.should == %w(contentaccessteam1)
   RoleMapper.whois('staff').sort.should == %w(staff1)

   RoleMapper.whois('stimutax salesman').empty?.should == true
 end

 after(:all) do
  #delete_all_users
  delete_all_users

  #Delete the roles
  delete_all_roles
 end 

end
