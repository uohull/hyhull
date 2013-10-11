require 'spec_helper'

# Test the Person model
# Person is readonly model that for test purposes is populated with the config/seeds.rb
# In Production Person is a view on person_db. 
# NOTE: Ensure that the Test DB has been seeded from config/seeds.rb 
describe Person do
 
 context "who exists" do
    describe '.person_by_username' do
      it "should return a Person object" do
        Person.person_by_username('staff1').should be_kind_of(Person)
      end
    end

    describe 'attributes' do
      before(:each) do
      	# Use the test person created by seeds.rb
      	@person = Person.person_by_username('archivist1')
      end
      it "should return all the required attributes" do
      	@person.username.should == "archivist1" #obviously...
      	@person.given_name.should == "archivist"
      	@person.family_name.should == "user"
      	@person.email_address.should == "archivist1@example.com"
        @person.user_type.should == "archivist"
        @person.department_ou.should == "LLI"
        @person.faculty_code.should == "123"
      end      
    end    
  end

  # A case when the user logged in doesn't exist in the people table
  context "who does not exist" do
    describe '.person_by_username' do
      it "should return a NullPerson object" do
        Person.person_by_username('Nobody').should be_kind_of(NullPerson)
      end
    end

    describe 'attributes' do
      before(:each) do
      	@null_person = Person.person_by_username('Nobody')
      end
      it "should default to guest types" do
        @null_person.user_type.should == "guest"
        @null_person.department_ou.should == "no_department"
        @null_person.faculty_code.should == "no_faculty"
        @null_person.email_address.should == "no email"
      end      
    end

  end 

end