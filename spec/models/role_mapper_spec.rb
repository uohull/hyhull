require 'spec_helper'
require 'user_helper'

describe RoleMapper do
  include UserHelper

  before (:all) do

    #Just incase they didn't get cleared out from previous tests...
    delete_all_users

    #create a test cat user
    @cat_user = User.create!(:username => "contentAccessTeam1", :email => "contentAccessTeam1@example.com")
    @cat_user.roles = [Role.find_or_initialize_by_name("contentAccessTeam")]

    #create a test cat user
    @staff_user = User.create!(:username => "staff1", :email => "staff1@example.com")
    @staff_user.roles = [Role.find_or_initialize_by_name("staff")]

  end

 it "should define the 5 roles" do  
   RoleMapper.role_names.include?("contentAccessTeam").should be_true
   RoleMapper.role_names.include?("contentCreator").should be_true
   RoleMapper.role_names.include?("guest").should be_true
   RoleMapper.role_names.include?("staff").should be_true
   RoleMapper.role_names.include?("student").should be_true
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
 end 

end
