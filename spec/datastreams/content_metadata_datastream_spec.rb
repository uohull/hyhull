# spec/datastreams/content_metadata_datastream_spec.rb
require 'spec_helper'

describe Hyhull::Datastream::ContentMetadata do
  before(:each) do
    @mods = fixture("hyhull/datastreams/contentMetadata.xml")
    @ds = Hyhull::Datastream::ContentMetadata.from_xml(@mods)
  end

  it "should expose content metadata using explicit terms and simple proxies" do
    #Explicit terms
    @ds.resource.resource_id.should == ["Document"]
    @ds.resource.sequence.should == ["1"]
    @ds.resource.display_label.should == ["Document"]
    @ds.resource.resource_object_id.should == ["hull:3112a"]
    @ds.resource.resource_ds_id.should == ["content"]
    @ds.resource.diss_type.should == ["genericContent/content"]
    @ds.resource.file.file_id.should == ["content"]
    @ds.resource.file.format.should == ["pdf"]
    @ds.resource.file.mime_type.should == ["application/pdf"]
    @ds.resource.file.size.should == ["26349568"]
    @ds.resource.file.location.should == ["http://hydra.hull.ac.uk/assets/hull:3112a/genericContent/content"]
    @ds.resource.file.date_created.should == []
    @ds.resource.file.date_last_modified.should == []
    @ds.resource.file.date_last_accessed.should == []
    @ds.resource.file.checksum.should == []

    #Simple proxies
    @ds.content_url.should == ["http://hydra.hull.ac.uk/assets/hull:3112a/genericContent/content"]
    @ds.content_format.should == ["pdf"]
    @ds.content_mime_type.should == ["application/pdf"]
    @ds.content_size.should == ["26349568"]
  end

end