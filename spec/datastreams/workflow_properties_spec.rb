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
      @ds.fields.depositorEmail.should == ["depositora@example.com"]
      @ds.fields.collection.should == ["uketd_object"]
      @ds.fields.state.should == ["proto"]   
    end
  end

  context "with a new ContentMetadata instance" do
    before(:each) do
      @workflow_properties_ds = Hyhull::Datastream::WorkflowProperties.new
    end

    it "should save the correct xml for the given data" do
      @workflow_properties_ds.fields.depositor = "aperson"
      @workflow_properties_ds.fields.depositorEmail = "aperson@example.com"
      @workflow_properties_ds.fields.collection = "video"
      @workflow_properties_ds.fields.state = "published"
      @workflow_properties_ds.to_xml.should be_equivalent_to("<fields><depositor>aperson</depositor><depositorEmail>aperson@example.com</depositorEmail><collection>video</collection><state>published</state></fields>")
    end
  end

end