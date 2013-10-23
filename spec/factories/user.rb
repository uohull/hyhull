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
		 factory :admin, class: User do
		   username "admin1"
		   email "admin1@example.com"
		   roles { [Role.find_or_initialize_by_name("admin")] }
		 end

	end

end
