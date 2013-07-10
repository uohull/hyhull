# encoding: utf-8
# spec/datastreams/mods_uketd_datastream_spec.rb
require 'spec_helper'

describe Datastream::ModsJournalArticle do
  before(:each) do
    @mods = fixture("hyhull/datastreams/journalarticle_descMetadata.xml")
    @ds = Datastream::ModsJournalArticle.from_xml(@mods)
  end

  it "should expose etd metadata for etd objects with explicit terms and simple proxies" do
    @ds.title.should == ["The title of the Journal article"]    
    @ds.abstract.should == ["Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."]
    @ds.subject_topic == ["Forms of knowledge", "University futures", "Learning technologies", "Knowledge economy"]
    @ds.topic_tag == ["Forms of knowledge", "University futures", "Learning technologies", "Knowledge economy"]
    @ds.rights == ["© 2010 The University of Hull"]
    @ds.identifier == ["hull:2376"]
    @ds.publisher == ["ICTD, University of Hull"]
    @ds.extent == ["Filesize: 64 MB"]
    @ds.mime_type == ["application/pdf"]
    @ds.digital_origin == ["born digital"]
    @ds.primary_display_url ==["http://hydra.hull.ac.uk/assets/hull:2376"]
    @ds.raw_object_url == ["http://hydra.hull.ac.uk/assets/hull:2376/genericContent/content"]
    @ds.record_creation_date == ["2010-04-14"]
    @ds.record_change_date == ["2010-04-15"]
    @ds.language_text == ["English"]

    #Names (personal and organisations)
    @ds.person_name.should == ["Smith, Peter"]
    @ds.person_role_text.should == ["Author"]
    @ds.person_role_code.should == []

    # Journal article specific terms..
    @ds.journal_title.should == ["Higher Education"]
    @ds.journal_publisher.should == ["Some journal publisher"]
    @ds.journal_publication_date.should == ["2007"]
    @ds.journal_print_issn.should == ["0018-1560"]
    @ds.journal_electronic_issn.should == ["1573-174X"]
    @ds.journal_article_doi.should == ["10.1007/s10734-007-9051-y"]
    @ds.journal_volume.should == ["54"]
    @ds.journal_issue.should == ["4"]
    @ds.journal_start_page.should == ["511"]
    @ds.journal_end_page.should == ["523"]
    @ds.journal_article_restriction.should == ["This is not restricted"]

    @ds.peer_reviewed.should == ["true"]

  end

  it "should expose nested/hierarchical metadata" do
    @ds.language.lang_text.should == ["English"]
    @ds.language.lang_code.should == ["eng"]
    @ds.origin_info.date_issued == ["2012-05-01"] 
    @ds.origin_info.publisher == ["The University of Hull"]
    @ds.physical_description.extent == ["Filesize: 228 KB"]
    @ds.physical_description.mime_type == ["application/pdf"]
    @ds.physical_description.digital_origin == ["born digital"]
    @ds.location_element.primary_display == ["http://hydra.hull.ac.uk/assets/hull:2376"]
    @ds.location_element.raw_object == ["http://hydra.hull.ac.uk/assets/hull:2376/genericContent/content"]
    @ds.record_info.record_creation_date == ["2010-04-14"]
    @ds.record_info.record_change_date == ["2010-04-15"]

    # Journal article specific terms...
    @ds.journal.journal_title_info.journal_main_title.should == ["Higher Education"]
    @ds.journal.origin_info.publisher.should ==  ["Some journal publisher"]
    @ds.journal.issn_print.should ==  ["0018-1560"]
    @ds.journal.issn_electronic.should == ["1573-174X"]
    @ds.journal.doi.should == ["10.1007/s10734-007-9051-y"]
    @ds.journal.part.volume.number.should == ["54"]
    @ds.journal.part.issue.number.should == ["4"]
    @ds.journal.part.pages.start.should == ["511"]
    @ds.journal.part.pages.end.should == ["523"]
    @ds.journal.note_restriction.should == ["This is not restricted"]
  end   


  describe "Set metadata methods" do
    before(:all) do
      @person_names = ["Smith, John.", "Jones, David."]
      @person_roles = ["Author", "Photographer"]
    end

    it "should let me update the names elements with multiple items" do
      #Add the names...
      @ds.add_names(@person_names, @person_roles, "person")

      #Test the names...
      @ds.person_name.should == @person_names
      @ds.person_role_text.should == @person_roles
    end

    it "should let me update subject_topic with multiple items" do
      new_subject_topics = ["New topic", "New topic 2"]
      @ds.add_subject_topic(new_subject_topics)
      @ds.subject_topic.should == new_subject_topics
    end
  end

  describe "class methods" do
    it "ModsEtd self.person_role_terms should only return the valid roles" do
      Datastream::ModsJournalArticle.person_role_terms.sort.should == ["Author"]
    end
  end

end