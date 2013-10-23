# spec/controllers/user_roles_controller_spec.rb
require 'spec_helper'

# Test class
class RolesControllerBehaviourTestClass
  include Hyhull::Controller::RolesControllerBehaviour
  attr_reader :role

  def initialize(role)
    @role = role
  end

  def role
    @role
  end

end

# This Hyhull::Controller::RolesControllerBehaviour spec will test the additional functionality added for  user_roles_controller
# hyhull simply makes a check that the user_role update is on a valid type of role 'hyhull_role_type'
# We don't want the ability to add users to different role_types like staff/student etc..
describe Hyhull::Controller::RolesControllerBehaviour do

  describe ".hyhull_role_type?" do

    it "should return true when it is hyhull role" do
      # admin is a role with hyhull RoleType
      hyhull_role = Role.find_by_name("admin")
      test_roles_controller = RolesControllerBehaviourTestClass.new(hyhull_role)

      test_roles_controller.hyhull_role_type?.should be_true
    end

    it "should return false when it isn't a hyhull role" do
      # staff is a role with user_role RoleType
      user_role = Role.find_by_name("staff")
      test_roles_controller = RolesControllerBehaviourTestClass.new(user_role)

      test_roles_controller.hyhull_role_type?.should be_false
    end
  end
end
