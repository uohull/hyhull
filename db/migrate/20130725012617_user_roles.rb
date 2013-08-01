class UserRoles < ActiveRecord::Migration
  def up
    create_table :role_types do |t|
      t.string :name
    end
    create_table :roles do |t|
      t.string :name
      t.string :description 
      t.belongs_to :role_type
    end
    create_table :roles_users, :id => false do |t|
      t.references :role
      t.references :user
    end
    add_index :roles_users, [:role_id, :user_id]
    add_index :roles_users, [:user_id, :role_id]
  end

  def down
    drop_table :roles_users
    drop_table :roles
    drop_table :role_types
  end
end
