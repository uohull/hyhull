# encoding: utf-8
# spec/datastreams/mods_uketd_datastream_spec.rb
require 'spec_helper'

describe Datastream::ModsGenericContent do
  before(:each) do
    @mods = fixture("hyhull/datastreams/generic_content_descMetadata.xml")
    @ds = Datastream::ModsGenericContent.from_xml(@mods)
  end

  it "should expose etd metadata for generic content objects with explicit terms and simple proxies" do
    @ds.title.should == ["Content models in the Hydra Project"] 
    @ds.description.should == ["Lorem ipsum dolor sit amet, consectetur adipisicing elit...."]
    @ds.subject_topic.should == ["Hydra"]
    @ds.subject_temporal.should == ["2012"]
    @ds.subject_geographic.should == ["Hull"]
    @ds.location_coordinates.should == ["12,40"]
    @ds.location_label.should == ["Location of Presentation"]
    @ds.location_coordinates_type.should == ["Point"]
    @ds.rights.should == ["© 2009 Richard Green. Creative Commons Licence: Attribution-Noncommercial-Share Alike 2.0 UK: England and Wales. See: http://creativecommons.org/licenses/by-nc-sa/2.0/uk/"]
    @ds.identifier.should == ["hull:2106", "hull-private:672"]
    @ds.extent.should == ["Filesize: 642KB"]
    @ds.publisher.should == ["The University of Hull"]
    @ds.mime_type.should == ["application/pdf"]
    @ds.digital_origin.should == ["born digital"]
    @ds.record_creation_date.should == ["2009-12-14"]
    @ds.record_change_date.should == ["2011-07-22"]
    @ds.language_text.should == ["English"]
    @ds.language_code.should == ["eng"]
    @ds.date_valid.should == ["2012-08"]

    #Names (personal and organisations)
    @ds.person_name.should == ["Green, Richard A."]
    @ds.person_role_text.should == ["Creator"]
    @ds.person_role_code.should == []

    @ds.organisation_name.should == ["Sponsor, A B."]
    @ds.organisation_role_text.should == ["Sponsor"]
    @ds.organisation_role_code.should == []
  end

  it "should expose nested/hierarchical metadata" do
    #Test are the terms that JournalArticle.title/publisher use - Note mods is needed to specific the root versions
    @ds.title_info.main_title.should == ["Content models in the Hydra Project"] 
    @ds.origin_info.date_valid.should == ["2012-08"] 
    @ds.subject.topic.should == ["Hydra"]
    @ds.subject.geographic.should == ["Hull"]
    @ds.subject.temporal.should == ["2012"]
    @ds.language.lang_text.should == ["English"]
    @ds.language.lang_code.should == ["eng"]
    @ds.origin_info.publisher.should == ["The University of Hull"]
    @ds.physical_description.extent.should == ["Filesize: 642KB"]
    @ds.physical_description.mime_type.should == ["application/pdf"]
    @ds.physical_description.digital_origin.should == ["born digital"]
    @ds.location_element.primary_display.should == ["http://hydra.hull.ac.uk/resources/hull:2106"]
    @ds.location_element.raw_object.should == ["http://hydra.hull.ac.uk/assets/hull:2106/genericContent/content"]
    @ds.record_info.record_creation_date.should == ["2009-12-14"]
    @ds.record_info.record_change_date.should == ["2011-07-22"]
  end   


  describe "Set metadata methods" do
    before(:all) do
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
      @ds.to_xml.include?('<name type=\"personal\"><namePart>Smith, John.</namePart><role><roleTerm type=\"text\">Author</roleTerm></role></name><name type=\"personal\"><namePart>Jones, David.</namePart><role><roleTerm type=\"text\">Photographer</roleTerm></role></name><name type=\"corporate\"><namePart>University of Hull</namePart><role><roleTerm type=\"text\">Funder</roleTerm></role></name><name type=\"corporate\"><namePart>Project Hydra</namePart><role><roleTerm type=\"text\">Sponsor</roleTerm></role></name>')
    end

    it "should let me update subject_topic with multiple items" do
      new_subject_topics = ["New topic", "New topic 2"]
      @ds.add_subject_topic(new_subject_topics)
      @ds.subject_topic.should == new_subject_topics
    end
  end

  describe "class methods" do
    it "ModsGenericContent self.person_role_terms should only return the valid roles" do
      Datastream::ModsGenericContent.person_role_terms.sort.should ==  ["Author", "Creator", "Editor", "Module leader", "Photographer", "Sponsor", "Supervisor"]
    end
    it "ModsGenericContent self.organisation_role_terms should only return the valid roles" do
      Datastream::ModsGenericContent.organisation_role_terms.sort.should ==  ["Creator", "Host", "Sponsor"]
    end
  end
  
end