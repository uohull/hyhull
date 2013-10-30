FactoryGirl.define do

	# This will guess the User class
	FactoryGirl.define do
		 factory :user do
           username "user"
		   email "user@example.com"
		   roles { ["guest"] }
		 end

		 # This will use the User class
		 factory :cat, class: User do
		   username "contentaccessteam1"
		   email "contentaccessteam1@example.com"
		   roles { [Role.find_or_initialize_by_name("contentAccessTeam")] }
		 end

		 # This will use the User class
		 factory :content_creator, class: User do
		   username "contentcreator1"
		   email "contentcreator1@example.com"
		   roles { [Role.find_or_initialize_by_name("contentCreator")] }
		 end

		 # This will use the User class 
		 factory :admin, class: User do
		   username "admin1"
		   email "admin1@example.com"
		   roles { [Role.find_or_initialize_by_name("admin")] }
		 end

		 # This will use the User class
		 factory :staff_user, class: User do
		   username "staff1"
		   email "staff1@example.com"
		 end

		 # This will use the User class
		 factory :student_user, class: User do
		   username "student1"
		   email "student1@example.com"
		 end

	end

end
