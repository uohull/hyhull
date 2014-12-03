# encoding: utf-8
# spec/datastreams/mods_book_chapter_spec.rb 
require 'spec_helper'

describe Datastream::ModsBookChapter do 

  describe "set_terminology" do    
      before(:each) do
        @mods = fixture("hyhull/datastreams/book_chapter_descMetadata.xml")
        @ds  = Datastream::ModsBookChapter.from_xml(@mods)
      end

      it "should expose book metadata with explicit terms and simple proxies" do
        # In the context of ModsBook chapter - title refers to the chapter
        @ds.title.should == ["Chapter title"]
        # Chapters can exist within books that are part of a series
        @ds.series_title.should == ["Test title series of the resource"]

        @ds.description.should == ["Lorem ipsum dolor sit amet, consectetur adipisicing elit...."]
        @ds.subject_topic.should == ["Something quite complicated"]
        @ds.rights.should == ["© 1999 The Author. All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holder."]
        @ds.identifier.should == ["hull:2106"]
        @ds.extent.should == ["Filesize: 64 MB" ]
        @ds.mime_type.should == ["application/pdf"]
        @ds.digital_origin.should == ["born digital"]
        @ds.record_creation_date.should == ["2013-02-18"]
        @ds.record_change_date.should == ["2013-03-25"]
        @ds.language_text.should == ["English"]
        @ds.language_code.should == ["eng"]

        # Publication info
        @ds.related_item_title.should == ["The publication title"]
        @ds.related_item_subtitle.should == ["The publication subtitle"]
        @ds.related_item_publisher.should == ["Made up University press"]
        @ds.related_item_date.should == ["1999"]
        @ds.related_item_issuance.should == ["monographic"]
        @ds.related_item_place.should == ["Ithaca, N.Y"]
        @ds.related_item_issue.should == ["1"]   
        @ds.related_item_volume.should == ["54"]

        @ds.related_item_start_page.should == ["23"]
        @ds.related_item_end_page.should == ["45"]

        @ds.related_item_physical_extent.should == ["vii, 322 p. ; 23 cm."]
        @ds.related_item_form.should == ["print"]

        # Related materials - web url #Uses like library catalogue record
        @ds.related_web_url.should == ["http://blacklight.hull.ac.uk/catalogue/ID"]

        # Resource publisher... 
        @ds.publisher == ["University of Hull"]

        #Names - Author and Editors
        @ds.person_name.should == ["Smith, John A", "Jones, Bobby A"]
        @ds.person_role_text.should == ["Author", "Editor"]
        @ds.person_role_code.should == []

        # Converis Pub ID / Ref related
        @ds.converis_publication_id.should == ["1234"]
        # Unit of assessement
        @ds.unit_of_assessment.should == ["Uoa 15"]

        # Standard hyhull fields
        @ds.primary_display_url.should == ["http://hydra.hull.ac.uk/resources/hull-test:132"]
        @ds.raw_object_url.should == ["http://hydra.hull.ac.uk/assets/hull-test:132a/content"]

       end

     it "should expose nested/hierarchical metadata" do
        # Using mods to ensure it selects the correct path
        #Test are the terms that JournalArticle.title/publisher use - Note mods is needed to specific the root versions
        @ds.mods.title_info.main_title.should == ["Chapter title"]
        @ds.mods.related_series_item.related_series_title_info.related_series_main_title.should == ["Test title series of the resource"]
        
        # Related Item 
        # Publication details
        @ds.mods.related_item.publication_origin_info.publication_date_issued.should == ["1999"]
        @ds.mods.related_item.publication_origin_info.publication_publisher.should == ["Made up University press"]
        @ds.mods.related_item.publication_origin_info.publication_issuance.should ==  ["monographic"]
        @ds.mods.related_item.publication_origin_info.publication_place.placeTerm.should == ["Ithaca, N.Y"]
        # Physical properties
        @ds.mods.related_item.related_item_physical_description.extent.should == ["vii, 322 p. ; 23 cm."]
        @ds.mods.related_item.related_item_physical_description.form ==  ["print"]

        @ds.mods.subject.topic.should ==  ["Something quite complicated"]
        @ds.mods.language.lang_text.should == ["English"]
        @ds.mods.language.lang_code.should == ["eng"]

        @ds.mods.physical_description.extent.should == ["Filesize: 64 MB"]
        @ds.mods.physical_description.mime_type.should == ["application/pdf"]
        @ds.mods.physical_description.digital_origin.should == ["born digital"]
        @ds.mods.record_info.record_creation_date.should ==  ["2013-02-18"]
        @ds.mods.record_info.record_change_date.should == ["2013-03-25"]

      end

   end

   describe "class_methods" do

      describe ".issuance_terms" do
         it "should return hash values that include the correct terms" do
           terms = Datastream::ModsBookChapter.issuance_terms

           terms["monographic"].should == "monographic"
           terms["single unit"].should == "single unit"
           terms["multipart monograph"].should == "multipart monograph"
           terms["continuing"].should == "continuing"
           terms["serial"].should == "serial"
           terms["integrating resource"].should == "integrating resource"
         end
      end

      describe ".form_terms" do
        it "should return hash values that include the correct terms" do
          terms  = Datastream::ModsBookChapter.marc_form_terms

          terms["Braille"].should == "braille"
          terms["Electronic"].should =="electronic"
          terms["Microfiche"].should ==  "microfiche"
          terms["Microfilm"].should == "microfilm"
          terms["Print"].should == "print"
          terms["Large print"].should == "large print"
        end
      end

  end
  
end
