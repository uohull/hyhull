# encoding: utf-8
# spec/datastreams/mods_set_spec.rb
require 'spec_helper'

describe Hyhull::Datastream::ModsSet do
  before(:each) do
    @mods = fixture("hyhull/datastreams/set_descMetadata.xml")
    @ds = Hyhull::Datastream::ModsSet.from_xml(@mods)
  end

  it "should expose etd metadata for set objects with explicit terms and simple proxies" do
    @ds.title.should == ["Photographs of the Library"]
    @ds.description.should == ["Library photos"]
    @ds.identifier.should == ["hull:test"]
    @ds.primary_display_url.should == ["http://hydra.hull.ac.uk/resources/changeme:197"]
    @ds.genre.should == ["Display Set"]
    @ds.type_of_resource.should == ["text"]
    @ds.publisher.should ==["The University of Hull"]
    @ds.resource_status.should == ["A collection of photographs"]
    @ds.date_issued.should == ["2013-07-19"]
  end

  it "should expose nested/hierarchical metadata" do
    @ds.title_info.main_title.should == ["Photographs of the Library"]
    @ds.origin_info.publisher.should == ["The University of Hull"]
    @ds.origin_info.date_issued.should == ["2013-07-19"]
    @ds.record_info.record_creation_date.should == ["2013-07-19"]
  end 

  describe "class methods" do
    it "xml_template should set the recordContentSource element to the DEFAULT_INSTITUTION_NAME configuration" do
      Hyhull::Datastream::ModsSet.xml_template.to_s.include?("<recordContentSource>#{DEFAULT_INSTITUTION_NAME}</recordContentSource>")
    end
  end 

end