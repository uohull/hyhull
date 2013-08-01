class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  belongs_to :role_type

  attr_accessible :name, :description, :role_type

  validates :name, 
    uniqueness: true,
    format: { with: /\A[a-zA-Z0-9._-]+\z/,
      :message => "Only letters, numbers, hyphens, underscores and periods are allowed"}

end
