# spec/datastreams/content_metadata_datastream_spec.rb
require 'spec_helper'

describe Hyhull::Datastream::WorkflowProperties do

  context "when loading from xml" do 
    before(:each) do
      @properties = fixture("hyhull/datastreams/properties.xml")
      @ds = Hyhull::Datastream::WorkflowProperties.from_xml(@properties)
    end

    it "should expose workflow properties using explicit terms" do
      #Explicit terms depositora@example.com
      @ds.fields.depositor.should == ["depositor_a"]
      @ds.fields.depositor_email.should == ["depositora@example.com"]
      @ds.fields.collection.should == ["uketd_object"]
      @ds.fields._resource_state.should == ["proto"]   
    end

    describe ".to_solr" do
      it "should generate the required solr fields" do
        @ds.to_solr["_resource_state_ssi"].should == "proto"
      end
    end
  end

  context "with a new ContentMetadata instance" do
    before(:each) do
      @workflow_properties_ds = Hyhull::Datastream::WorkflowProperties.new
    end

    it "should save the correct xml for the given data" do
      @workflow_properties_ds.fields.depositor = "aperson"
      @workflow_properties_ds.fields.depositor_email = "aperson@example.com"
      @workflow_properties_ds.fields.collection = "video"
      @workflow_properties_ds.fields._resource_state = "published"
      @workflow_properties_ds.to_xml.should be_equivalent_to("<fields><depositor>aperson</depositor><depositorEmail>aperson@example.com</depositorEmail><collection>video</collection><resourceState>published</resourceState></fields>")
    end
  end


end