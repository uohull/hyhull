# spec/datastreams/mods_uketd_datastream_spec.rb
require 'spec_helper'

describe Datastream::ModsEtd do
  before(:each) do
    @mods = fixture("hyhull/datastreams/etd_descMetadata.xml")
    @ds = Datastream::ModsEtd.from_xml(@mods)
  end

  it "should expose etd metadata for etd objects with explicit terms and simple proxies" do
    @ds.title.should == ["My dissertation on the results of..."]
    @ds.abstract.should == ["Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."]
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

    #Names (personal and organisations)
    @ds.person_name.should == ["Smith, John A.","Supervisor A."]
    @ds.person_role_text.should == ["creator","Supervisor"]
    @ds.person_role_code.should == []

    @ds.organisation_name.should == ["Sponsor, A B."]
    @ds.organisation_role_text.should == ["sponsor"]
    @ds.organisation_role_code.should == []

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

  describe "Set metadata methods" do
    before(:each) do
      @person_names = ["Smith, John.", "Jones, David."]
      @person_roles = ["Author", "Photographer"]
      @organisation_names = ["University of Hull", "Project Hydra"]
      @organisation_roles = ["Funder", "Sponsor"]
    end

    it "should let me update the names elements with multiple items" do
      #Add the names...
      @ds.add_names(@person_names, @person_roles, "person")
      @ds.add_names(@organisation_names, @organisation_roles, "organisation")

      #Test the names...
      @ds.person_name.should == @person_names
      @ds.person_role_text.should == @person_roles
      @ds.organisation_name.should == @organisation_names
      @ds.organisation_role_text.should == @organisation_roles
    end

    it "add_names should add the MODS elements in the correct form" do
      #Add the names...
      @ds.add_names(@person_names, @person_roles, "person")
      @ds.add_names(@organisation_names, @organisation_roles, "organisation")
      @ds.to_xml.include?('<name type="personal"><namePart>Smith, John.</namePart><role><roleTerm type="text">Author</roleTerm></role></name><name type="personal"><namePart>Jones, David.</namePart><role><roleTerm type="text">Photographer</roleTerm></role></name><name type="corporate"><namePart>University of Hull</namePart><role><roleTerm type="text">Funder</roleTerm></role></name><name type="corporate"><namePart>Project Hydra</namePart><role><roleTerm type="text">Sponsor</roleTerm></role></name>')
    end

    it "should let me update subject_topic with multiple items" do
      new_subject_topics = ["New topic", "New topic 2"]
      @ds.add_subject_topic(new_subject_topics)

      @ds.subject_topic.should == new_subject_topics
    end

    it "should let me update grant_number with multiple items" do
      new_grant_numbers = ["gn:123455", "56333"]
      @ds.add_grant_number(new_grant_numbers)
      @ds.grant_number.should == new_grant_numbers
    end
  end

  describe "class methods" do
    it "ModsEtd self.person_role_terms should only return the valid roles" do
      Datastream::ModsEtd.person_role_terms.sort.should == ["Creator", "Sponsor", "Supervisor"]
    end
     it "ModsEtd self.organisation_role_terms should only return the valid roles" do
      Datastream::ModsEtd.organisation_role_terms.sort.should ==  ["Sponsor"]
    end
  end

end