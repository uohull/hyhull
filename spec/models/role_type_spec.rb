require 'spec_helper'

# Test the RoleType model
# The RoleType ActiveRecord based model defines the type of roles that exist within hyhull
# At time of writing, the RoleTypes within Hyhull are - user, hyhull, department_ou, faculty_code
# NOTE: Ensure that the Test DB has been seeded from config/seeds.rb 

describe RoleType do

  describe '.user_role_type' do
    it "should return user RoleType instance" do
      subject.class.user_role_type.should be_an_instance_of RoleType  
    end
    it "should return the correct role type string" do
      subject.class.user_role_type.name.should eq("user")
    end
  end

  describe '.hyhull_role_type' do
    it "should return hyhull RoleType instance" do
      subject.class.hyhull_role_type.should be_an_instance_of RoleType
    end
    it "should return the correct role type string" do
      subject.class.hyhull_role_type.name.should eq("hyhull")
    end
  end

  describe '.department_ou_role_type' do
    it "should return department ou RoleType be_an_instance_ofstance" do
      subject.class.department_ou_role_type.should be_an_instance_of RoleType
    end
    it "should return the correct role type string" do
      subject.class.department_ou_role_type.name.should eq("department_ou")
    end
  end

  describe '.faculty_code_role_type' do
    it "should return faculty code RoleType instance" do
       subject.class.faculty_code_role_type.should be_an_instance_of RoleType
    end
    it "should return the correct role type string" do
      subject.class.faculty_code_role_type.name.should eq("faculty_code")
    end
  end

end