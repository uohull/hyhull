require 'spec_helper'

describe Hyhull::ModsMetadataMethods do

  before(:each) do
    # Lets create an object we know that implements ModsMetadataMethods...
    @mods = fixture("hyhull/datastreams/etd_descMetadata.xml")
    @ds = Datastream::ModsEtd.from_xml(@mods)

    @file_asset_datastream = double("file_asset_datastream", size: 12345, mimeType: "application/pdf", )
    @file_asset = double("file_asset", content: @file_asset_datastream, pid: "test:1235567")    
  end

  describe "update_mods_content_metadata" do
    it "should return true with the appropiate parameters" do
      @ds.update_mods_content_metadata(@file_asset , "content").should == true      
    end
   
    it "should set the appropiate mods metadata fields" do
      @ds.update_mods_content_metadata(@file_asset , "content")
      @ds.physical_description.extent.should == ["12 KB"] 
      @ds.physical_description.mime_type == ["application/pdf"]
      @ds.raw_object_url.should == ["http://hydra.hull.ac.uk/assets/test:1235567/content"]
    end
  end
 
  describe "bits_to_human_readable method" do
    it "should return the correct readable string for a range of examples" do
      @ds.class.bits_to_human_readable(900).should == "900 bytes"
      @ds.class.bits_to_human_readable(1024).should == "1 KB"
      @ds.class.bits_to_human_readable(100089).should == "97 KB"
      @ds.class.bits_to_human_readable(987654321).should == "941 MB"
      @ds.class.bits_to_human_readable(2147483648).should == "2 GB"
      @ds.class.bits_to_human_readable(5497558138880).should == "5 TB"
    end
  end 

end
