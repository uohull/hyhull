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
  end

  def down 
     unless Rails.env.production?
      drop table :person
    end
  end
  
end
