require 'spec_helper'

# Test the Role model
# The Role ActiveRecord based model defines a role that a user may have. 
# For example a role might be 'contentAccessTeam' for users who are a member of that team
# It also may be something as generic as Staff, Student or guest.
# NOTE: Test Roles are created in seeds.rb, this Role spec file relies on those Roles in the test db to pass  

describe Role do
  context "match role helpers" do

    describe ".match_user_role_by_name" do
      it "should match the valid role student" do
        # The return should be of Role class, be equal to student and persisted (i.e. in the db)
        subject.class.match_user_role_by_name("student").should be_instance_of Role
        subject.class.match_user_role_by_name("student").name.should eq("student")
        subject.class.match_user_role_by_name("student").persisted?.should be_true
      end

      it "should match the valid role staff" do
        subject.class.match_user_role_by_name("staff").should be_instance_of Role
        subject.class.match_user_role_by_name("staff").name.should eq("staff")
        subject.class.match_user_role_by_name("staff").persisted?.should be_true
      end

      it "should not match an invalid role" do
        # Role should not return a role with the name wizard - it doesn't exist
        subject.class.match_user_role_by_name("wizard").name.should_not eq("wizard")
      end

      # User can have a valid user role (e.g. staff) or default to guest
      it "should return the default guest role when an invalid role is queried" do
        # Role should not return a role with the name squire - it doesn't exist
        subject.class.match_user_role_by_name("squire").name.should_not eq("squire")
        # however it should be default return the 'guest' role 
        subject.class.match_user_role_by_name("squire").name.should eq("guest")
        # It will be persisted because it is returning guest...
        subject.class.match_user_role_by_name("squire").persisted?.should be_true
      end
    end 

    describe ".match_department_role_by_name" do
      it "should match the valid role IT" do
        subject.class.match_department_role_by_name("IT").should be_instance_of Role
        subject.class.match_department_role_by_name("IT").name.should eq("IT")
        subject.class.match_department_role_by_name("IT").persisted?.should be_true
      end

      it "should match the valid role LLI" do
        subject.class.match_department_role_by_name("LLI").should be_instance_of Role
        subject.class.match_department_role_by_name("LLI").name.should eq("LLI")
        subject.class.match_department_role_by_name("LLI").persisted?.should be_true
      end

      # If the user's department role doesn't match existing departments in the database
      it "should not match an invalid role" do
        # AC doesn't exist... 
        subject.class.match_department_role_by_name("AC").should_not eq("AC")
        # The return should be a Role object
        subject.class.match_department_role_by_name("AC").should be_instance_of Role
        # However it should include the text 'no_department'
        subject.class.match_department_role_by_name("AC").name.should eq("no_department")
        # It will be persisted because it is returning no_department
        subject.class.match_department_role_by_name("AC").persisted?.should be_true
      end
    end

    describe ".match_faculty_role_by_name" do      
      it "should match the valid role 123" do
        subject.class.match_faculty_role_by_name("123").should be_instance_of Role
        subject.class.match_faculty_role_by_name("123").name.should eq("123")       
      end

      it "should match the valid role 456" do
        subject.class.match_faculty_role_by_name("456").should be_instance_of Role
        subject.class.match_faculty_role_by_name("456").name.should eq("456")
        subject.class.match_faculty_role_by_name("456").persisted?.should be_true
      end

      # If the user's faculty role doesn't match existing faculties in the database
      it "should not match an invalid role" do
        # 789 so don't return a match
        subject.class.match_faculty_role_by_name("789").should_not eq("789")        
        # The return should be a Role object
        subject.class.match_faculty_role_by_name("789").should be_instance_of Role
        # The return should be the default faculty role 'no_faculty'
        subject.class.match_faculty_role_by_name("789").name.should eq("no_faculty")
        # It will be persisted because it is returning no_faculty
        subject.class.match_faculty_role_by_name("789").persisted?.should be_true
      end
    end

  end

end