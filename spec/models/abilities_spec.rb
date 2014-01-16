require 'spec_helper'
require 'cancan/matchers'

 # Hydra::Ability will handle the individual rights for edit/updates of Resources based upon rightsMetadata
 # The local hyhull Ability class provides customised abilities for the application - This spec file will test those local rules.
describe "Abilities" do
  subject(:ability) { Ability.new(user) }
  let(:user) { nil }

  # All hyhull resources use the same abilties, so using ExamPaper as an example
  describe "ExamPaper" do
    describe ".create_permissions" do
     
      # These users should NOT be able to create or invoke initial step of a resource...
      context "when is a public user" do
        it { should_not be_able_to(:initial_step, ExamPaper.new) }
        it { should_not be_able_to(:create, ExamPaper.new) }
      end  

      context "when is a staff user" do
        let(:user) { FactoryGirl.create(:staff_user) }
        it { should_not be_able_to(:initial_step, ExamPaper.new) }
        it { should_not be_able_to(:create, ExamPaper.new) }
      end

      context "when is a student user" do
        let(:user) { FactoryGirl.create(:student_user) }
        it { should_not be_able_to(:initial_step, ExamPaper.new) }
        it { should_not be_able_to(:create, ExamPaper.new) }
      end

      #These users SHOULD be able to create resources....
      context "when is a content creator" do
        let(:user) { FactoryGirl.create(:content_creator) }
        it { should be_able_to(:initial_step, ExamPaper.new) }
        it { should be_able_to(:create, ExamPaper.new) }
      end

      context "when is a contentAccessTeam" do
        let(:user) { FactoryGirl.create(:cat) }
        it { should be_able_to(:initial_step, ExamPaper.new) }
        it { should be_able_to(:create, ExamPaper.new) }
      end

      context "when is a admin" do
        let(:user) { FactoryGirl.create(:admin) }
        it { should be_able_to(:initial_step, ExamPaper.new) }
        it { should be_able_to(:create, ExamPaper.new) }
      end
    end    
  end


  # Testing the abilities related to StructuralSets
  # - ie TreeView
  describe "StructuralSet" do
    describe ".custom_permissions" do      
      # Only admin and contentAccessTeam have access to the treeview and update_permissions

      #treeview
      context "when is a contentAccessTeam" do
        let(:user) { FactoryGirl.create(:cat) }
        it { should be_able_to(:tree, StructuralSet.new) }
      end

      context "when is a admin" do
        let(:user) { FactoryGirl.create(:admin) }
        it { should be_able_to(:tree, StructuralSet.new) }
      end

      #update_permissions
      context "when is a contentAccessTeam" do
        let(:user) { FactoryGirl.create(:cat) }
        it { should be_able_to(:update_permissions, StructuralSet.new) }
      end

      context "when is a admin" do
        let(:user) { FactoryGirl.create(:admin) }
        it { should be_able_to(:update_permissions, StructuralSet.new) }
      end

      # Content creators should not....
      context "when is a contentCreator" do
        let(:user) { FactoryGirl.create(:content_creator) }
        it { should_not be_able_to(:tree, StructuralSet.new) }
      end

      context "when is a contentCreator" do
        let(:user) { FactoryGirl.create(:content_creator) }
        it { should_not be_able_to(:update_permissions, StructuralSet.new) }
      end

      # Lets be on the safe side and test for public...
      context "when is a public user" do
        it { should_not be_able_to(:tree, StructuralSet.new) }
      end

      context "when is a public user" do
        it { should_not be_able_to(:update_permissions, StructuralSet.new) }
      end

    end
  end

  # Testing the abilities related to DisplaySets
  # - ie TreeView
  describe "DisplaySet" do
    describe ".custom_permissions" do
      # Only admin and contentAccessTeam have access to the treeview and update_permissions
      # treeview
      context "when is a contentAccessTeam" do
        let(:user) { FactoryGirl.create(:cat) }
        it { should be_able_to(:tree, DisplaySet.new) }
      end

      context "when is a admin" do
        let(:user) { FactoryGirl.create(:admin) }
        it { should be_able_to(:tree, DisplaySet.new) }
      end

      #update_permissions
      context "when is a contentAccessTeam" do
        let(:user) { FactoryGirl.create(:cat) }
        it { should be_able_to(:update_permissions, DisplaySet.new) }
      end

      context "when is a admin" do
        let(:user) { FactoryGirl.create(:admin) }
        it { should be_able_to(:update_permissions, DisplaySet.new) }
      end

      # Content creators should not....
      context "when is a contentCreator" do
        let(:user) { FactoryGirl.create(:content_creator) }
        it { should_not be_able_to(:tree, DisplaySet.new) }
      end

      context "when is a contentCreator" do
        let(:user) { FactoryGirl.create(:content_creator) }
        it { should_not be_able_to(:update_permissions, DisplaySet.new) }
      end

      # Lets be on the safe side and test for public...
      context "when is a public user" do
        it { should_not be_able_to(:tree, DisplaySet.new) }
      end

      context "when is a public user" do
        it { should_not be_able_to(:update_permissions, DisplaySet.new) }
      end

    end
  end

  describe "Role" do
    describe ".custom_permissions" do      
      # Admin users are the only ones that modify roles
      context "when is a admin" do
        let(:user) { FactoryGirl.create(:admin) }
        it { should be_able_to(:show, Role.find_or_initialize_by_name(HYHULL_USER_GROUPS[:content_creator])) }
        it { should be_able_to(:add_user, Role.find_or_initialize_by_name(HYHULL_USER_GROUPS[:content_creator])) }
        it { should be_able_to(:remove_user, Role.find_or_initialize_by_name(HYHULL_USER_GROUPS[:content_creator])) }
        it { should be_able_to(:index, Role.find_or_initialize_by_name(HYHULL_USER_GROUPS[:content_creator])) }
      end

      # These users should NOT be able modify roles
      context "when is a cat" do
        let(:user) { FactoryGirl.create(:cat) }
        it { should_not be_able_to(:show, Role.find_or_initialize_by_name(HYHULL_USER_GROUPS[:content_creator])) }
        it { should_not be_able_to(:add_user, Role.find_or_initialize_by_name(HYHULL_USER_GROUPS[:content_creator])) }
        it { should_not be_able_to(:remove_user, Role.find_or_initialize_by_name(HYHULL_USER_GROUPS[:content_creator])) }
        it { should_not be_able_to(:index, Role.find_or_initialize_by_name(HYHULL_USER_GROUPS[:content_creator])) }
      end

      # These users should NOT be able modify roles
      context "when is public" do
        it { should_not be_able_to(:show, Role.find_or_initialize_by_name(HYHULL_USER_GROUPS[:content_creator])) }
        it { should_not be_able_to(:add_user, Role.find_or_initialize_by_name(HYHULL_USER_GROUPS[:content_creator])) }
        it { should_not be_able_to(:remove_user, Role.find_or_initialize_by_name(HYHULL_USER_GROUPS[:content_creator])) }
        it { should_not be_able_to(:index, Role.find_or_initialize_by_name(HYHULL_USER_GROUPS[:content_creator])) }
      end
    end
  end

  # Property is model used to store various properties in Hydra
  describe "Property" do
    describe ".custom_permissions" do
      before(:all) do
        @property_name = "Business School"
      end      
      # Admin users are the only ones that modify roles
      context "when user is a admin" do
        let(:user) { FactoryGirl.create(:admin) }
        it { should be_able_to(:show, Property.find_or_initialize_by_name(@property_name))}
        it { should be_able_to(:index, Property.find_or_initialize_by_name(@property_name))}
        it { should be_able_to(:update, Property.find_or_initialize_by_name(@property_name))}
        it { should be_able_to(:destroy, Property.find_or_initialize_by_name(@property_name))}
      end

      # These users should NOT be able modify roles
      context "when user is a cat" do
        let(:user) { FactoryGirl.create(:cat) }
        it { should_not be_able_to(:show, Property.find_or_initialize_by_name(@property_name))}
        it { should_not be_able_to(:index, Property.find_or_initialize_by_name(@property_name))}
        it { should_not be_able_to(:update, Property.find_or_initialize_by_name(@property_name))}
        it { should_not be_able_to(:destroy, Property.find_or_initialize_by_name(@property_name))}
      end

      # These users should NOT be able modify roles
      context "when user is public" do
        it { should_not be_able_to(:show, Property.find_or_initialize_by_name(@property_name))}
        it { should_not be_able_to(:index, Property.find_or_initialize_by_name(@property_name))}
        it { should_not be_able_to(:update, Property.find_or_initialize_by_name(@property_name))}
        it { should_not be_able_to(:destroy, Property.find_or_initialize_by_name(@property_name))}
      end
    end
  end

  # PropertyType model (only index available) - no manage operations at present
  describe "PropertyType" do
    describe ".custom_permissions" do
      # Admin users are the only ones that modify roles
      context "when user is a admin" do
        let(:user) { FactoryGirl.create(:admin) }
        it { should be_able_to(:index, PropertyType) }
      end

      # These users should NOT be able modify roles
      context "when user is a cat" do
        let(:user) { FactoryGirl.create(:cat) }
        it { should_not be_able_to(:index, PropertyType) }
      end

      # These users should NOT be able modify roles
      context "when user is public" do
        it { should_not be_able_to(:index, PropertyType) }
      end
    end
  end

  # In hyhull we have overridden the permissions of ActiveFedora::Based so that it's not just based upon whether the user is an editor.
  # Resources can only be deleted when their resource_state is proto, qa or deleted.  Resources in other state CANNOT be deleted
  describe "UketdObject" do
    describe "destroy custom_permissions" do
     
      # Test fixture hull:756 is a published resource with contentAccessTeam edit rights
      context "when resource is in published state" do
        let(:user) { FactoryGirl.create(:cat) }
        it { should_not be_able_to(:destroy, UketdObject.find("hull:756") ) }
      end

      # Test fixture hull:3108 is in proto (deleteable) with contentAccessTeam edit rights
      context "when resource is in proto state" do
        let(:user) { FactoryGirl.create(:cat) }
        # So it should be deletable...
        it { should be_able_to(:destroy, UketdObject.find("hull:3108") ) }
      end

      # Test fixture hull:3573 is in QA (deleteable) with contentAccessTeam edit rights
      context "when resource is in proto state" do
        let(:user) { FactoryGirl.create(:cat) }
        # So it should be deletable...
        it { should be_able_to(:destroy, UketdObject.find("hull:3573") ) }
      end

      # Deletable state, but not by the user specified.
      context "when resource is in proto state" do
        let(:user) { FactoryGirl.create(:content_creator) }
        it { should_not be_able_to(:destroy, UketdObject.find("hull:3108") ) }
      end

    end

  end


end
