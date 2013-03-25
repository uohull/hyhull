# spec/datastreams/mods_uketd_datastream_spec.rb
require 'spec_helper'

describe ModsUketd do
  before(:each) do
    @mods = fixture("hyhull/datastreams/etd_descMetadata.xml")
    @ds = ModsUketd.from_xml(@mods)
  end

  it "should expose etd metadata for etd objects with explicit terms and simple proxies" do
    @ds.mods.title_info.main_title.should == ["My dissertation on the results of..."]    
    @ds.title.should == ["My dissertation on the results of..."]
    @ds.abstract.should == ["Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."]
    @ds.author_name == ["Smith, John A."]
    @ds.supervisor_name == ["Supervisor A."]
    @ds.sponsor_name == ["Sponsor, A B."]
    @ds.subject_topic == ["Something quite complicated"]
    @ds.topic_tag == ["Something quite complicated"]
    @ds.rights == ["&#xA9; 2001 The Author. All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holder."]
    @ds.identifier == ["hull-test:132"]
    @ds.grant_number == ["GN:09879"]
    @ds.date_issued == ["2001-03"]
    @ds.publisher == ["ICTD, University of Hull"]
    @ds.extent == ["Filesize: 64 MB"]
    @ds.mime_type == ["application/pdf"]
    @ds.digital_origin == ["born digital"]
    @ds.primary_display_url ==["http://hydra.hull.ac.uk/resources/hull-test:132"]
    @ds.raw_object_url == ["http://hydra.hull.ac.uk/assets/hull-test:132a/content"]
    @ds.record_creation_date == ["2013-02-18"]
    @ds.record_change_date == ["2013-03-25"]
    @ds.language_text == ["English"]
  end
  
  it "should expose nested/hierarchical metadata" do
    @ds.language.lang_text.should == ["English"]
    @ds.language.lang_code.should == ["eng"]
    @ds.origin_info.date_issued == ["2001-03"] 
    @ds.origin_info.publisher == ["ICTD, University of Hull"]
    @ds.physical_description.extent == ["Filesize: 64 MB"]
    @ds.physical_description.mime_type == ["application/pdf"]
    @ds.physical_description.digital_origin == ["born digital"]
    @ds.location_element.primary_display == ["http://hydra.hull.ac.uk/resources/hull-test:132"]
    @ds.location_element.raw_object == ["http://hydra.hull.ac.uk/assets/hull-test:132a/content"]
    @ds.record_info.record_creation_date == ["2013-02-18"]
    @ds.record_info.record_change_date == ["2013-03-25"]  
  end
end