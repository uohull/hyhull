class CreatePerson < ActiveRecord::Migration
  def up
  	unless Rails.env.production?
  		create_table :person do |t|
      	t.string :User_name
       	t.string :Forename
       	t.string :Surname
       	t.string :EmailAddress
       	t.string :type
       	t.string :DepartmentOU
       	t.string :SubDepartmentCode
     	end
  	end

  	if Rails.env.test?
  		   ActiveRecord::Base.connection.execute("INSERT INTO person (User_name, Forename, Surname, EmailAddress, type, DepartmentOU, SubDepartmentCode) VALUES ('contentAccessTeam1', 'content', 'team', 'contentAccessTeam1@example.com', 'contentAccessTeam', 'Dep', 'SubDep')")
  	end

  end

  def down
  	unless Rails.env.production?
  		drop table :person
  	end
  end
  
end
