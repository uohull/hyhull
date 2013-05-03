require 'spec_helper'

describe FileAsset do

  before(:each) do
    @file_asset = FileAsset.create
  end

  describe "cmodel" do
    it "should properly return the appropriate RELS-EXT cModel declaration (Upper CamelCase for Hydra FileAsset model)" do
      @file_asset.rels_ext.to_rels_ext.include?('info:fedora/afmodel:FileAsset').should == true
    end
  end

end