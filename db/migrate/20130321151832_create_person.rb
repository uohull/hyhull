class CreatePerson < ActiveRecord::Migration
  def up
  	unless Rails.env.production?
      create_table :people do |t|
        t.string :username
        t.string :given_name
        t.string :family_name
        t.string :email_address
        t.string :user_type
        t.string :department_ou
        t.string :faculty_code
      end
  	end

  	if Rails.env.test?
  		   ActiveRecord::Base.connection.execute("INSERT INTO people (username, given_name, family_name, email_address, user_type, department_ou, faculty_code) VALUES ('contentAccessTeam1', 'content', 'team', 'contentAccessTeam1@example.com', 'contentAccessTeam', 'Dep', 'SubDep')")
  	end
  end

  def down 
     unless Rails.env.production?
      drop table :person
    end
  end
  
end
