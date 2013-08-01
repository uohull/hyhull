class RoleType < ActiveRecord::Base
  has_many :roles
  attr_accessible :name
end