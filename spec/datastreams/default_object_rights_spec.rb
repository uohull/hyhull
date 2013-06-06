require 'spec_helper'

describe Hyhull::Datastream::DefaultObjectRights do
  before(:each) do
    @default_object_rights_ds = Hyhull::Datastream::DefaultObjectRights.new
  end

  it "should inherit from Hydra::Datastream::RightsMetadata" do
    @default_object_rights_ds.kind_of?  Hydra::Datastream::RightsMetadata
  end

  it "should allow me to set permissions like a Hydra::Datastream::RightsMetadata datastream" do
    @default_object_rights_ds.update_permissions({"group"=>{"baz"=>"edit", "staff"=>"read", "students"=>"none"}})
    @default_object_rights_ds.groups.should == {"staff"=>"read", "baz"=>"edit"}

    @default_object_rights_ds.update_permissions({"person"=>{"tom"=>"edit", "harry"=>"read", "john"=>"none"}})
    @default_object_rights_ds.individuals.should == {"harry"=>"read", "tom"=>"edit"}
  end

  # Hyhull::Datastream::DefaultObjectRights should not produce any sort of solr fields that could get tangled with
  # the a resources 'rightsMetadata'. 
  it "should not produce solr fields" do
    @default_object_rights_ds.update_permissions({"group"=>{"baz"=>"edit", "staff"=>"read", "students"=>"none"}})
    @default_object_rights_ds.groups.should == {"staff"=>"read", "baz"=>"edit"} 
    # to_solr should add no solr fields to the passed object
    @default_object_rights_ds.to_solr("").should == ""
  end

end