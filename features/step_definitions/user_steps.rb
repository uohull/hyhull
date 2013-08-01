Given /^I am logged in as "([^\"]*)"$/ do |username|

  email = "#{username}@example.com"
  today = Date.today 

  # Test users set in db/seeds.rb
  #Get the relevant reference to the roles...
  if username.include? "staff"
    role = Role.find_or_initialize_by_name("staff")
  elsif username.include? "student"
    role = Role.find_or_initialize_by_name("student")
  elsif username.include? "contentAccessTeam"
   role = Role.find_or_initialize_by_name("contentAccessTeam")
  elsif username.include? "archivist"
   role = Role.find_or_initialize_by_name("archivist")
  else
   role = Role.find_or_initialize_by_name("guest")
  end

  @current_user = User.create!(:username => username, :email => email)  
  #Add the role
  @current_user.roles = [role]
  User.find_by_email(email).should_not be_nil

  #Uses the warden helper method to log a user in without needed to use a CAS login... 
  login_as @current_user, :scope => :user

  visit catalog_index_path

 #visit destroy_user_session_path
 #visit new_user_session_path
 # fill_in "Email", :with => email 
 # fill_in "Password", :with => "password"
 # click_button "Sign in"
 step %{I should see a link to "logout"} 
end

Given /^I am a superuser$/ do
  step %{I am logged in as "bigwig@example.com"}
  bigwig_id = User.find_by_email("bigwig@example.com").id
  superuser = Superuser.create(:id => 20, :user_id => bigwig_id)
  visit superuser_path
end