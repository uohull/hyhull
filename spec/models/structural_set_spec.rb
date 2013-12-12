# encoding: utf-8
# spec/models/structural_set_spec.rb
require 'spec_helper'


class ChildObjectTestClass < ActiveFedora::Base
  include Hyhull::ModelMethods

  has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata

  belongs_to :parent, property: :is_member_of, :class_name => "StructuralSet"

  def title 
    "Test resource"
  end

  def date_valid
    "2010-01-01"
  end

  def genre
    "Test genre"
  end

  def resource_state
    "published"
  end

  def resource_published?
    true
  end

  def owner_id
    "fooAdmin"
  end

  def initialize
    super
  end

end

class ChildWithQueingMixin < ActiveFedora::Base
  include Hyhull::ModelMethods
  include Hyhull::ResourceWorkflowBehaviour

  has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata

  belongs_to :parent, property: :is_member_of, :class_name => "StructuralSet"

  def owner_id
    "fooAdmin"
  end
end

describe StructuralSet do
  
  context "original spec" do
    before(:each) do
      # Create a new structural_set object for the tests... 
      @structural_set = StructuralSet.new
    end

    it "should have the specified datastreams" do
      #Check for descMetadata datastream
      @structural_set.datastreams.keys.should include("descMetadata")
      @structural_set.descMetadata.should be_kind_of Hyhull::Datastream::ModsSet
      @structural_set.descMetadata.label.should == "MODS metadata"

      #Check for the rightsMetadata datastream
      @structural_set.datastreams.keys.should include("rightsMetadata")
      @structural_set.rightsMetadata.should be_kind_of Hydra::Datastream::RightsMetadata
      @structural_set.rightsMetadata.label.should == "Rights metadata"

      #Check for the defaultObjectRights datastream
      @structural_set.datastreams.keys.should include("defaultObjectRights")
      @structural_set.defaultObjectRights.should be_kind_of Hyhull::Datastream::DefaultObjectRights
      @structural_set.defaultObjectRights.label.should == "Default object rights"

      #Check for the properties datastream
      @structural_set.datastreams.keys.should include("properties")
      @structural_set.properties.should be_kind_of Hyhull::Datastream::WorkflowProperties

    end

    it "genre should be set to 'Structural set'" do
      @structural_set.genre.should == "Structural set"
    end

    it "should have the attributes of an structural set object and support update_attributes" do
      attributes_hash = {
        "title" => "Artwork",
        "description" => "University collection of Artwork",
        "resource_status" => "Currently empty",
        "type_of_resource" => "mixed material"
      } 

      @structural_set.update_attributes( attributes_hash )
      @structural_set.title.should == attributes_hash["title"]
      @structural_set.description.should == attributes_hash["description"]
      @structural_set.resource_status.should == attributes_hash["resource_status"]
      @structural_set.type_of_resource.should == attributes_hash["type_of_resource"]
    end

    it "should have the required relationships" do
      @structural_set.respond_to?(:parent).should == true
      @structural_set.respond_to?(:apo).should == true
      @structural_set.respond_to?(:children).should == true
      @structural_set.respond_to?(:apo_children).should == true
    end

    it "should return a tree" do
      root_node = StructuralSet.tree
      root_node.print_tree

      # There should be more than one child///
      root_node.children.size.should > 1

      puts "Attempting to get options for select"
      options = root_node.options_for_nested_select

      options.each {|v| puts "#{v[0]} = #{v[1]}" }
    end

    it "should return json" do
      root_node = StructuralSet.tree

      puts "Attempting to get json from tree"
      json = root_node.to_json

      json.include?("label").should be_true
      json.include?("id").should be_true

      json.include?("name").should be_false
      json.include?("content").should be_false
    end

    it "should enforce validation on title and parent" do
      @structural_set.save.should == false
      @structural_set.errors.messages.should == {:title=>["can't be blank"], :parent=>["can't be blank"]} 
    end

    it "should do provide a set of options for a fedora_select nested select" do
      options = StructuralSet.tree.options_for_nested_select
      options.each {|v| puts "#{v[0]} = #{v[1]}" }
    end

    describe "a saved instance" do
      before do
        @instance = StructuralSet.new
        @instance.title = "Test set"
        @instance.parent_id = "hull:rootSet"        
        @instance.save

          @instance = StructuralSet.find(@instance.id)
      end
      
      it "should have defaultObjectRights datastream" do
        @instance.defaultObjectRights.content.should be_equivalent_to '
  <rightsMetadata xmlns="http://hydra-collab.stanford.edu/schemas/rightsMetadata/v1">
    <copyright>
      <human></human>
      <machine></machine>
    </copyright>
    <access type="discover">
      <human></human>
      <machine>
        <group>contentAccessTeam</group>
      </machine>
    </access>
    <access type="read">
      <human></human>
      <machine>
        <group>contentAccessTeam</group>
      </machine>
    </access>
    <access type="edit">
      <human></human>
      <machine>
        <group>contentAccessTeam</group>
      </machine>
    </access>
    <use>
      <human></human>
      <machine></machine>
    </use>
    <embargo>
      <human></human>
      <machine></machine>
    </embargo>
  </rightsMetadata>
  '
    end

    it "should be governedBy " do
      @instance.apo.id.should == "hull-apo:structuralSet"
    end

    it "should index only the rightsMetadata (not defaultObjectRights)" do
      # A new structural set should always inherit the defaultObjectRights of
      # its parent and have an isGovernedBy to hull-apo:structuralSet.  If it is
      # a top level set it will inherit its defaultObjectRights from
      # hull:rootSet
      # 
      # The rightsMetadata for *any* structural set is 'contentAccessTeam' only
      # which is in the apo and what all the 'isGovernedBy' relationships
      # ensure. - RightsMetadata always comes from an APO.
      @instance.defaultObjectRights.edit_access.machine.group.should == ["contentAccessTeam"]
      ## @instance.rightsMetadata should be copied from its governing structural set's defaultObjectRights
      @instance.rightsMetadata.edit_access.machine.group.should == ['contentAccessTeam']
      @instance.to_solr["discover_access_group_ssim"].should == ['contentAccessTeam']
    end

    it "apply_depositor_metadata should not update the rightsMetadata" do
      @instance.apply_depositor_metadata("Me", "me@example.com")
      @instance.depositor.should == "Me"
      @instance.depositor_email.should == "me@example.com"
      # Unlile in the Hyhull::Models variant apply_depositor_metadata should not set the rightsMetadata to the edit by the individual 
      @instance.rightsMetadata.individuals.should == {}   
    end

    after do
      @instance.delete
    end
  end
  
  end

  describe "inheritance" do
    before do
      @instance = StructuralSet.new
      @instance.title = "A test set"
 
      @parent = StructuralSet.new
      @parent.title = "A parent set"
      @parent.parent_id = "hull:rootSet"
      @parent.save
      # Change the parents defaulObjectRights
      @parent.defaultObjectRights.update_permissions("person"=>{"baz"=>"edit"})
      @parent.save
    end
    it "should inherit the rightsMetadata and defaultObjectRights from the parents defaultObjectRights when the parent structuralSet is updated" do
      @instance.parent = @parent
      @instance.apply_default_object_rights
      # instance should inherit the baz 'edit' rights defined in the parent above... 
      @instance.defaultObjectRights.individuals["baz"].should == "edit"
      # Save will invoke the apply_default_object_rights via the before_create callback
      @instance.save
      # Lets check the defaultObjectRights once more...
      @instance.defaultObjectRights.individuals["baz"].should == "edit"
    end
    after do
      @instance.delete
      @parent.delete
    end    
  end

  describe "structural set recursive permissions" do
    before do
      @permission_params = {"group"=>{"public"=>"read", "contentAccessTeam"=>"edit"}}
      alt_permission_params = {"group"=>{"staff"=>"read", "public"=>"none", "contentAccessTeam"=>"edit"}} 

      @parent = StructuralSet.new
      @parent.title = "Parent set"
      #Set the parent to hull:rootSet... 
      @parent.parent_id = "hull:rootSet"
      @parent.save
      @parent.defaultObjectRights.update_permissions(@permission_params)
      @parent.save

      # Matching set
      @first_child = StructuralSet.new
      @first_child.title = "First child set" 
      @first_child.parent = @parent
      @first_child.save  # Inherits rights from parent...     
      
      @first_child.defaultObjectRights.update_permissions(@permission_params)
      @first_child.save

      # Non-Matching set
      @second_child = StructuralSet.new
      @second_child.title = "Second child set"
      @second_child.parent = @parent 
      @second_child.save  # Inherits rights from parent...

      @second_child.defaultObjectRights.update_permissions(alt_permission_params)
      @second_child.save

      # Child of matching set
      @first_child_content_object = ChildObjectTestClass.new
      @first_child_content_object.save
      @first_child_content_object.rightsMetadata.update_permissions(@permission_params)
      @first_child_content_object.parent = @first_child
      #@first_child_content_object.apply_set_membership(["info:fedora/" + @first_child.pid])
      #@first_child_content_object.apply_governed_by("info:fedora/" +  @first_child.pid)
      @first_child_content_object.save

      # Child of non-matching set
      @second_child_content_object = ChildObjectTestClass.new
      @second_child_content_object.save
      @second_child_content_object.rightsMetadata.update_permissions(alt_permission_params)
      @second_child_content_object.parent = @second_child
      #@second_child_content_object.apply_set_membership(["info:fedora/" + @second_child.pid])
      #@second_child_content_object.apply_governed_by("info:fedora/" + @second_child.pid)
      @second_child_content_object.save
    end

    it "should return a list of all children" do
      ancestors_ = StructuralSet.ancestry @parent.pid 

      ancestors_.should include({"active_fedora_model_ssi"=>"StructuralSet", "id"=>@first_child.pid, "title_tesim"=>[@first_child.title], "is_member_of_ssim"=>["info:fedora/#{@parent.pid}"]},
                           {"active_fedora_model_ssi"=>"StructuralSet", "id"=>@second_child.pid, "title_tesim"=>[@second_child.title], "is_member_of_ssim"=>["info:fedora/#{@parent.pid}"]},
                           {"active_fedora_model_ssi"=>"ChildObjectTestClass", "id"=>@first_child_content_object.pid, "is_member_of_ssim"=>["info:fedora/#{@first_child.pid}"]},
                           {"active_fedora_model_ssi"=>"ChildObjectTestClass", "id"=>@second_child_content_object.pid, "is_member_of_ssim"=>["info:fedora/#{@second_child.pid}"]})
    end
    it "should return correctly the list of matching and non-matching children" do
        @parent.match_ancestors_default_object_rights.should == {
                                                                 :dont_match=>[{:active_fedora_model_ssi=>"StructuralSet", :id=> @second_child.pid},
                                                                               {:active_fedora_model_ssi=>"ChildObjectTestClass", :id=> @second_child_content_object.pid}], 
                                                                 :match=>[{:active_fedora_model_ssi=>"StructuralSet", :id=>@first_child.pid},
                                                                          {:active_fedora_model_ssi=>"ChildObjectTestClass", :id=>@first_child_content_object.pid}]
                                                                }

    end
    it "should update the permissions of matching children only" do
      new_permission_params = {"group"=>{"contentAccessTeam"=>"none", "public"=>"none", "baz"=>"edit"}}
  
      @parent.update_permissions(new_permission_params, "defaultObjectRights") 

      #Reload the children from fedora...
      @first_child = StructuralSet.find(@first_child.pid)
      @first_child_content_object = ChildObjectTestClass.find(@first_child_content_object.pid)
      @second_child = StructuralSet.find(@second_child.pid)
      @second_child_content_object = ChildObjectTestClass.find(@second_child_content_object.pid)
     
      #Matching child should have been updated...
      @parent.defaultObjectRights.groups.should == {"baz"=>"edit"}
      @first_child.defaultObjectRights.groups.should == {"baz"=>"edit"}
      @first_child_content_object.rightsMetadata.groups.should == {"baz"=>"edit"}

      #Non-matching children don't update...
      @second_child.defaultObjectRights.groups.should == {"staff"=>"read", "contentAccessTeam"=>"edit"}
      @second_child_content_object.rightsMetadata.groups.should == {"staff"=>"read", "contentAccessTeam"=>"edit"} 
    end

    it "should update the direct child resources of a set" do
      # Test written replicate a previous issue...

      new_permission_params = {"group"=>{"contentAccessTeam"=>"none", "public"=>"none", "baz"=>"edit"}}
      # Yet another set...
      # Matching set
      yet_another_set = StructuralSet.new
      yet_another_set.title = "Yet another set" 
      yet_another_set.parent = @parent
      yet_another_set.save  # Inherits rights from parent... 

      yet_another_set.defaultObjectRights.groups.should == {"public"=>"read", "contentAccessTeam"=>"edit"} 

      # Child of matching set
      yet_another_child_resource = ChildWithQueingMixin.new
      yet_another_child_resource.save

      yet_another_child_resource.resource_state = "published"
      yet_another_child_resource.parent = yet_another_set
      yet_another_child_resource.save

      # Should inherit sets rights as default... 
      yet_another_child_resource.rightsMetadata.groups.should == {"public"=>"read", "contentAccessTeam"=>"edit"} 

      yet_another_set.update_permissions(new_permission_params,"defaultObjectRights")
      # Reload the child resource from fedora... 
      yet_another_child_resource.reload 
      # Child should have inherited the parent params... 
      yet_another_child_resource.rightsMetadata.groups.should == {"baz"=>"edit"}

      yet_another_set.delete
      yet_another_child_resource.delete
    end

    after do
      @parent.delete
      @first_child.delete
      @first_child_content_object.delete
      @second_child.delete
      @second_child_content_object.delete
    end
  end


end
