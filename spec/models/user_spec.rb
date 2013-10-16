require 'spec_helper'

# User class has been extended for use within Hyhull.  
# Hyhull uses CAS for authentication - User is populated with username based upon the valid CAS login
# When a user logs in, a user.save is invoked, before this happens the users details are updated.  
# The User's role and attributes are populated via a lookup to the 'People' database table (used be other services)
# This spec will test methods provided by hyhull user class

# At present Users 'hydra' roles will not change unless they are changed manually (via inteface/db). This means that even if the users user_type/department/faculty change, the hydra role will remain same. 

describe User do
  context "who exists within the People table" do
    
    describe "with user department and faculty attributes" do
      # We need a test users - seeds creates a number of 'people' so we will use one of those...
      before(:each) do
        @test_student_user = User.new
        @test_student_user.username = "student1"

        @test_staff_user = User.new
        @test_staff_user.username = "staff1"
      end
      
      # Delete the users for subsequent tests
      after(:each) do
        @test_student_user.delete
        @test_staff_user.delete        
      end

      # The follow attributes exist within the people table
      # username: 'student1',  given_name: 'student', family_name: 'user', email_address: 'student1@example.com',user_type: 'student', department_ou: 'CompSci', faculty_code: '456'
      it "student user should be populated from people table on .save" do
         @test_student_user.save
         # before_save will call update_user_attributes 
         @test_student_user.email.should eq("student1@example.com") 
         # This implicity tests the private methods get_combined_user_organisation_roles, role_of_type methods           
         @test_student_user.groups.should include("student", "CompSci", "456", "456_student", "CompSci_student")
      end

      it "staff user should be populated from people table on .save" do
        @test_staff_user.save
        # before_save will call update_user_attributes 
        @test_staff_user.email.should eq("staff1@example.com") 
        # This implicity tests the private methods get_combined_user_organisation_roles, role_of_type methods           
        @test_staff_user.groups.should include("staff", "IT", "123", "IT_staff", "123_staff")
      end
    end


    # When a user's person (people) attribute changes, the user's roles should change too. 
    describe "person attribute changes" do
      before (:each) do
        # Create a test person record
        @researcher_person = Person.new
        @researcher_person.username = "researcher2"
        @researcher_person.given_name = "The"
        @researcher_person.family_name = "Researcher"
        @researcher_person.email_address = "researcher2@example.com"
        @researcher_person.user_type = "staff"
        @researcher_person.department_ou = "CompSci"
        @researcher_person.faculty_code = "456"
        @researcher_person.save

        # Create a test user based on person
        @researcher_user = User.new
        @researcher_user.username = "researcher2"
        @researcher_user.save

      end
      after(:each) do
        @researcher_user.delete
        @researcher_person.delete
      end

      it "user attributes be correct before a person update" do
        @researcher_user.email.should eq("researcher2@example.com")
        @researcher_user.groups.should include("staff", "CompSci", "456", "CompSci_staff", "456_staff")
      end

      it "should update the user e-mail address correctly" do

        # Because People have read-only attributes (Rails side)...
        # We have to delete the person record and recreate with the new attributes to make this test work as expected 
        @researcher_person.delete
        researcher_person = Person.new
        researcher_person.username = "researcher2"
        researcher_person.given_name = "The"
        researcher_person.family_name = "Researcher"
        researcher_person.email_address = "new_researcher2_address@example.com" # This has changed
        researcher_person.user_type = "staff"
        researcher_person.department_ou = "CompSci"
        researcher_person.faculty_code = "456"
        researcher_person.save
	
        # simulate a login and the before_save event.. 
        @researcher_user.send(:update_user_attributes)
        # Test that it is updated in ther record
        @researcher_user.email.should eql("new_researcher2_address@example.com")
      end

      it "should update the user_role correctly" do
        # Because People have read-only attributes (Rails side)...
        # We have to delete the person record and recreate with the new attributes to make this test work as expected 
        @researcher_person.delete
        researcher_person = Person.new
        researcher_person.username = "researcher2"
        researcher_person.given_name = "The"
        researcher_person.family_name = "Researcher"
        researcher_person.email_address = "researcher2@example.com"
        researcher_person.user_type = "student" # This has changed
        researcher_person.department_ou = "CompSci"
        researcher_person.faculty_code = "456"
        researcher_person.save

      	# simulate a login and the before_save event.. 
        @researcher_user.send(:update_user_attributes)
        @researcher_user.groups.should include("student", "CompSci", "456", "CompSci_student", "456_student")
      end

      it "should update the user department_role correctly" do
        # Because People have read-only attributes (Rails side)...
        # We have to delete the person record and recreate with the new attributes to make this test work as expected 
        @researcher_person.delete
        researcher_person = Person.new
        researcher_person.username = "researcher2"
        researcher_person.given_name = "The"
        researcher_person.family_name = "Researcher"
        researcher_person.email_address = "researcher2@example.com"
        researcher_person.user_type = "staff"
        researcher_person.department_ou = "IT" # This has changed
        researcher_person.faculty_code = "456"
        researcher_person.save

      	# simulate a login and the before_save event.. 
        @researcher_user.send(:update_user_attributes)
        @researcher_user.groups.should include("staff", "IT", "456", "IT_staff", "456_staff")
      end

      it "should update the user faculty_role correctly" do
        # Because People have read-only attributes (Rails side)...
        # We have to delete the person record and recreate with the new attributes to make this test work as expected 
        @researcher_person.delete
        researcher_person = Person.new
        researcher_person.username = "researcher2"
        researcher_person.given_name = "The"
        researcher_person.family_name = "Researcher"
        researcher_person.email_address = "researcher2@example.com"
        researcher_person.user_type = "staff"
        researcher_person.department_ou = "CompSci" 
        researcher_person.faculty_code = "123" # This has changed
        researcher_person.save

      	# simulate a login and the before_save event.. 
        @researcher_user.send(:update_user_attributes)
        @researcher_user.groups.should include("staff", "CompSci", "123", "CompSci_staff", "123_staff")
      end
    end

    describe "with specfic hydra roles" do    
      before(:each) do
      	# User to be a content creator
        @content_creator_user = User.new
        @content_creator_user.username = "bigwig" 
        @content_creator_user.save 

        # content creator role
        @content_creator_role = Role.where(name: "contentCreator").first
        # content access team role
        @content_access_team_role = Role.where(name: "contentAccessTeam").first   
      end

      after(:each) do
        @content_creator_user.delete
      end      

      it "should retain their user, department and faculty roles when a new hydra role is added" do
        # before adding create rights...
        # We use user.groups to get string list of roles
        @content_creator_user.groups.should include("staff", "LLI", "123", "LLI_staff", "123_staff")

        # We add the contentCreator rights to a user from the role side...
        # first lets confirm that bigwig isn't already a content creator
        @content_creator_role.users.should_not include("bigwig")

        # Add the @content_creator_user to the list
        @content_creator_role.users << @content_creator_user

        # Content Creator User - bigwig should now include the contentCreator role
        @content_creator_user.reload.groups.should include("contentCreator", "staff", "LLI", "123", "LLI_staff", "123_staff")

      end

      it "should retain their user, department and faculty roles when a hydra role is removed" do
        # Add content_creator_user to the contentAccessTeam role
        @content_access_team_role.users << @content_creator_user
        # We use user.groups to get string list of roles
        @content_creator_user.reload.groups.should include("contentAccessTeam")

        # Remove the content access team role from the user
        @content_creator_user.roles.delete(@content_access_team_role)

        # This shouldn't remain...
        @content_creator_user.reload.groups.should_not include("contentAccessTeam")
        # These should remain...
        @content_creator_user.groups.should include("staff", "LLI", "123", "LLI_staff", "123_staff")   
      end 

    end

  end

end
