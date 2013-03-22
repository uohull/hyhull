FactoryGirl.define do

  # Prototype user factory
  factory :user, :aliases => [:owner] do |u|
    sequence :username do |n|
      "person#{username}"
    end
    username {username}
    email { "#{uid}@example.com" }   
    new_record false
  end


  factory :cat, :parent=>:user do |u|
  	uid 'contentAccessTeam1'
  	email 'contentaccessteam1@example.com'
  	roles { ["contentAccessTeam"] }   
  end

  factory :staff, :parent=>:user do |u|
  	username 'staff1'
  	email 'staff1@example.com'
  	roles { ["staff"] }    
  end

  factory :student, :parent=>:user do |u|
  	username 'student1'
  	email 'student1@example.com'
  	roles { ["student"] }   
  end


  factory :cat_role, :parent => :role do |u|
    name "contentAccessTeam"
    description "contentAccessTeam"
    association :users, factory: :cat    
  end

end