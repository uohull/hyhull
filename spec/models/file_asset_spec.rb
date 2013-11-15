require 'spec_helper'

describe FileAsset do

  before(:each) do
    @file_asset = FileAsset.create
  end

  describe "FullTextDatastreamBehaviour" do
    it "should be included as part of the module" do
      @file_asset.class.ancestors.should include(Hyhull::FullTextDatastreamBehaviour)
    end
  end
  

  describe "class" do
    it "should have the specified datastreams" do
      #Check for descMetadata datastream
      @file_asset.datastreams.keys.should include("descMetadata")
      @file_asset.descMetadata.should be_kind_of ActiveFedora::QualifiedDublinCoreDatastream
      @file_asset.descMetadata.label.should == "Qualified DC"

      #Check for the rightsMetadata datastream
      @file_asset.datastreams.keys.should include("rightsMetadata")
      @file_asset.rightsMetadata.should be_kind_of Hydra::Datastream::RightsMetadata
      @file_asset.rightsMetadata.label.should == "Rights metadata"
    end
  end

  describe "cmodel" do
    it "should properly return the appropriate RELS-EXT cModel declaration (Upper CamelCase for Hydra FileAsset model)" do
      @file_asset.rels_ext.to_rels_ext.include?('info:fedora/afmodel:FileAsset').should == true
    end
  end
end
