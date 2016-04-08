# encoding: utf-8
# spec/datastreams/mods_uketd_datastream_spec.rb
require 'spec_helper'

describe Datastream::ModsJournalArticle do
  before(:each) do
    @mods = fixture("hyhull/datastreams/journalarticle_descMetadata.xml")
    @ds = Datastream::ModsJournalArticle.from_xml(@mods)
  end

  it "should expose journal article metadata for journal objects with explicit terms and simple proxies" do
    # Removed due to issue with matching two fields 
    #@ds.title.should == ["The title of the Journal article"]  

    @ds.abstract.should == ["Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."]
    @ds.subject_topic.should == ["Forms of knowledge", "University futures", "Learning technologies", "Knowledge economy"]
    @ds.rights.should == ["© 2010 The University of Hull"]
    @ds.mods.identifier.should == ["hull:2376"]

    # Removed due to issue with matching two fields 
    # @ds.publisher == ["ICTD, University of Hull"]
    @ds.extent.should == ["Filesize: 228 KB"]
    @ds.mime_type.should == ["application/pdf"]
    @ds.digital_origin.should == ["born digital"]
    @ds.primary_display_url.should ==["http://hydra.hull.ac.uk/assets/hull:2376"]
    @ds.raw_object_url.should == ["http://hydra.hull.ac.uk/assets/hull:2376/genericContent/content"]
    @ds.record_creation_date.should == ["2010-04-14"]
    @ds.record_change_date.should == ["2010-04-15"]
    @ds.language_text.should == ["English"]

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
    @ds.journal_publications_note.should == ["This Journal can be accessed via..."]
    @ds.journal_date_other.should == ["2015-11-15"]

    # Journal article related URLs...
    @ds.journal_url.should == ["http://www.sampleurl.com/2323434/splash", "http://www.sampleurl.com/2323434/document.pdf", "http://www.sampleurl.com/2323434/abstract.html"]
    @ds.journal_url_access.should == ["object in context", "raw object", "preview"]
    @ds.journal_url_display_label.should == ["Article splash", "Full text", "Abstract"]

    @ds.peer_reviewed.should == ["true"]

    # Converis Pub ID
    @ds.converis_publication_id.should == ["1234"]
    # Unit of assessement
    @ds.unit_of_assessment.should == ["Uoa 15"]

  end

  it "should expose nested/hierarchical metadata" do

    #Test are the terms that JournalArticle.title/publisher use - Note mods is needed to specific the root versions
    @ds.mods.title_info.main_title.should == ["The title of the Journal article"]  
    @ds.mods.origin_info.publisher.should == ["The University of Hull"]

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
    @ds.journal.note_publications.should == ["This Journal can be accessed via..."]
    # @ds.journal_date_other.should == ["2015-11-15"]
    @ds.journal.journal_origin_info.journal_date_other.should == ["2015-11-15"]
    # Journal location urls
    @ds.journal.location.url.should == ["http://www.sampleurl.com/2323434/splash", "http://www.sampleurl.com/2323434/document.pdf", "http://www.sampleurl.com/2323434/abstract.html"]
    @ds.journal.location.url.access.should == ["object in context", "raw object", "preview"]
    @ds.journal.location.url.display_label.should == ["Article splash", "Full text", "Abstract"]

    # Converis Pub ID
    @ds.converis_related.publication_id.should == ["1234"]

    # RIOXX
    @ds.apc.should == ["Paid"]    
    @ds.project_id == ["1234a"]
    @ds.project_funder_id == ["A funder name"]
    @ds.project_funder_name == ["5678b"]
    @ds.free_to_read_start_date == ["2015-11-15"]
    @ds.free_to_read_end_date == ["2016-11-15"]
    @ds.licence_url == ["http://licence-url.com"]
    @ds.licence_ref_start_date == ["2016-03-21"]
    @ds.ref_version == ["AO"]
    @ds.depositor_note == ["A depositor note..."]
  end   


  describe "Set metadata method" do
    
    describe "roles" do
      before(:all) do
        @person_names = ["Smith, John.", "Jones, David."]
        @person_roles = ["Author", "Photographer"]
        @person_affiliation = ["Department of library", "Department of Physics"]
      end

      it "should let me update the names elements with multiple items" do
        #Add the names...
        @ds.add_names(@person_names, @person_roles, "person", @person_affiliation)

        #Test the names...
        @ds.person_name.should == @person_names
        @ds.person_role_text.should == @person_roles
        @ds.person_affiliation.should == @person_affiliation
      end
    end

    describe "subjects" do
      it "should let me update subject_topic with multiple items" do
        new_subject_topics = ["New topic", "New topic 2"]
        @ds.add_subject_topic(new_subject_topics)
        @ds.subject_topic.should == new_subject_topics
      end
    end

    describe "journal urls" do
      it "should let me update related journal urls with related access type and display labels" do
         url_list = [
           "http://www.sampleurl.com/2323434/splash",
           "http://www.sampleurl.com/2323434/document.pdf",
           "http://www.sampleurl.com/2323434/abstract.html"
         ]

         url_access_list = [
           "object in context",
           "raw object",
           "preview"
         ]

         url_display_label_list = [
           "Article splash page",
           "Full text",
           "Preview"
         ]

        # Add the urls, access type, and labels
        @ds.add_journal_urls(url_list, url_access_list, url_display_label_list)

        # Check they are set correct...
        @ds.journal.location.url.should == url_list
        @ds.journal.location.url.access.should == url_access_list
        @ds.journal.location.url.display_label.should == url_display_label_list
      end
    end
  
  end

  describe "class methods" do
    it "ModsEtd self.person_role_terms should only return the valid roles" do
      Datastream::ModsJournalArticle.person_role_terms.sort.should == ["Author", "Contributor"]
    end

    it "xml_template should set the recordContentSource element to the DEFAULT_INSTITUTION_NAME configuration" do
      Datastream::ModsJournalArticle.xml_template.to_s.include?("<recordContentSource>#{DEFAULT_INSTITUTION_NAME}</recordContentSource>")
    end
  end

end