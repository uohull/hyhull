# encoding: utf-8

require 'spec_helper'

# Create a test class to consume the Hyhull::Datastream::ModsMetadataBase terminology
class ModsForResourceTestClass < ActiveFedora::OmDatastream
  include Hyhull::Datastream::ModsMetadataBase 
end

describe Hyhull::Datastream::ModsMetadataBase do

 context "default terminology" do

    before(:each) do
      @mods = fixture("hyhull/datastreams/mods_metadata.xml")
      @ds = ModsForResourceTestClass.from_xml(@mods)
    end

    it "should expose metadata for generic resource with explicit terms and simple proxies" do
      @ds.title.should == ["Content models in the Hydra Project"]
      @ds.version.should == ["Version 1.0"]
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
      @ds.date_issued.should == ["2013"]
      @ds.mods.doi.should == ["doi:123"]
      @ds.resource_status.should == ["This is an admin note..."]
      @ds.additional_notes.should == ["More notes here..."]
      @ds.citation.should == ["Cite with:"]
      @ds.software.should == ["Ubuntu Linux"]

      @ds.primary_display_url.should == ["http://hydra.hull.ac.uk/resources/hull:2106"]
      @ds.raw_object_url.should == ["http://hydra.hull.ac.uk/assets/hull:2106/genericContent/content"]

      # Related item article specific terms..
      @ds.related_item_title.should == ["Other version title"]
      @ds.related_item_publisher.should ==  ["Other version publisher"]
      @ds.related_item_publication_date.should == ["2007"]
      @ds.related_item_print_issn.should == ["1234-4321"]
      @ds.related_item_isbn.should ==  ["45354634543"]
      @ds.related_item_electronic_issn.should == ["1234-4321X"]
      @ds.related_item_doi.should == ["1.009/345456"]
      @ds.related_item_volume.should == ["54"]
      @ds.related_item_issue.should == ["4"]
      @ds.related_item_start_page.should == ["511"]
      @ds.related_item_end_page.should == ["523"]
      @ds.related_item_restriction.should == ["This is not restricted"]
      @ds.related_item_publications_note.should == ["This Journal can be accessed via..."]

      # Related item URLs...
      @ds.related_item_url.should == ["http://www.sampleurl.com/2323434/splash", "http://www.sampleurl.com/2323434/document.pdf", "http://www.sampleurl.com/2323434/abstract.html"]
      @ds.related_item_url_access.should == ["object in context", "raw object", "preview"]
      @ds.related_item_url_display_label.should == ["Article splash", "Full text", "Abstract"]

      # Converis id
      @ds.converis_publication_id.should == ["12345"]

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
      @ds.mods.title_info.main_title.should == ["Content models in the Hydra Project"]
      @ds.mods.title_info.part_name.should == ["Version 1.0"]
      @ds.origin_info.date_valid.should == ["2012-08"] 
      @ds.origin_info.date_issued.should == ["2013"] 
      @ds.subject.topic.should == ["Hydra"]
      @ds.subject.geographic.should == ["Hull"]
      @ds.subject.temporal.should == ["2012"]
      @ds.language.lang_text.should == ["English"]
      @ds.language.lang_code.should == ["eng"]
      @ds.mods.origin_info.publisher.should == ["The University of Hull"]
      @ds.physical_description.extent.should == ["Filesize: 642KB"]
      @ds.physical_description.mime_type.should == ["application/pdf"]
      @ds.physical_description.digital_origin.should == ["born digital"]
      @ds.mods.location_element.primary_display.should == ["http://hydra.hull.ac.uk/resources/hull:2106"]
      @ds.mods.location_element.raw_object.should == ["http://hydra.hull.ac.uk/assets/hull:2106/genericContent/content"]
      @ds.record_info.record_creation_date.should == ["2009-12-14"]
      @ds.record_info.record_change_date.should == ["2011-07-22"]

      # Related item specific terms...
      @ds.related_item.related_item_title_info.related_item_main_title.should == ["Other version title"]
      @ds.related_item.origin_info.publisher.should ==  ["Other version publisher"]
      @ds.related_item.issn_print.should ==  ["1234-4321"]
      @ds.related_item.issn_electronic.should == ["1234-4321X"]
      @ds.related_item.related_doi.should == ["1.009/345456"]
      @ds.related_item.isbn.should == ["45354634543"]
      @ds.related_item.part.volume.number.should == ["54"]
      @ds.related_item.part.issue.number.should == ["4"]
      @ds.related_item.part.pages.start.should == ["511"]
      @ds.related_item.part.pages.end.should == ["523"]
      @ds.related_item.note_restriction.should == ["This is not restricted"]
      @ds.related_item.note_publications.should == ["This Journal can be accessed via..."]
      # Related item location urls
      @ds.related_item.location.url.should == ["http://www.sampleurl.com/2323434/splash", "http://www.sampleurl.com/2323434/document.pdf", "http://www.sampleurl.com/2323434/abstract.html"]
      @ds.related_item.location.url.access.should == ["object in context", "raw object", "preview"]
      @ds.related_item.location.url.display_label.should == ["Article splash", "Full text", "Abstract"]

      # Converis id
      @ds.converis_related.publication_id.should == ["12345"]
      # Unit of assessement
      @ds.unit_of_assessment.should == ["Uoa 15"]
      @ds.peer_reviewed.should == ["true"]
    end

 end 



  context "content-specific metadata" do
    before(:each) do
      # Lets create an object we know that implements  Hyhull::Datastream::ModsMetadataBase...
      @mods = fixture("hyhull/datastreams/etd_descMetadata.xml")
      @ds = Datastream::ModsEtd.from_xml(@mods)

      @file_asset_datastream = double("file_asset_datastream", size: 12345, mimeType: "application/pdf", )
      @file_asset = double("file_asset", content: @file_asset_datastream, pid: "test:1235567", datastreams: {"content" => @file_asset_datastream })
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

  context "class method" do
  
    describe "all_rights_reserved_statement" do
      it "should return the correct text for a single person and year" do
        Datastream::ModsEtd.all_rights_reserved_statement("John Smith", "2001").should == "© 2001 John Smith. All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holder."
      end
      it "should return the correct state for two people and year" do
        Datastream::ModsEtd.all_rights_reserved_statement(["John Smith", "John Jones"], "2005").should == "© 2005 John Smith and John Jones. All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holders."
      end
      it "should return the correct state for more than two people and year" do
        Datastream::ModsEtd.all_rights_reserved_statement(["John Smith", "John Jones", "Frank Spencer"], "2001").should == "© 2001 John Smith, John Jones and Frank Spencer. All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holders."
      end 
    end

    describe "coordinates_types" do
      it "should return the valid values" do
        Datastream::ModsEtd.coordinates_types.should == {"Path" => "LineString", "Polygon" => "Polygon", "Point" => "Point" }
      end
    end

    describe "url_access_terms" do
      it "will return the valid values" do
        Datastream::ModsEtd.url_access_terms.should == { "preview" => "preview", "raw object" => "raw object", "object in context" => "object in context" }
      end
    end

  end

end
