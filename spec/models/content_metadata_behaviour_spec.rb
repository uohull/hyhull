require 'spec_helper'

class ContentMetadataBehaviourTest < ActiveFedora::Base
  include Hyhull::ContentMetadataBehaviour

  def owner_id
    "fooAdmin"
  end

  def initialize
    super
  end

end


describe Hyhull::ModelMethods do

  before(:each) do
    @testclassone = ContentMetadataBehaviourTest.new
  end

  describe "datastream_behaviour" do
    it "should define the contentMetadata Hyhull::Datastream::ContentMetadata as a metadata datastream" do
      @testclassone.datastreams.should include('contentMetadata')
      @testclassone.contentMetadata.should be_an_instance_of(Hyhull::Datastream::ContentMetadata)
    end
  end

  describe "delegates" do
    it "should return the appropiate delegates" do
      @testclassone.sequence.should == []
      @testclassone.display_label.should == []
      @testclassone.resource_object_id.should == []
      @testclassone.resource_ds_id.should == []
      @testclassone.content_id.should == []
    end
  end

end
