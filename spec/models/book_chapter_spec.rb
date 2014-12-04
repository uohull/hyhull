# encoding: utf-8
# spec/models/book_chapter_spec.rb
require 'spec_helper'

describe BookChapter do

    context "original spec" do
      before(:each) do
        @book_chapter = BookChapter.new
      end

      it "should have the specified datastreams" do
        #Check for descMetadata datastream
        @book_chapter.datastreams.keys.should include("descMetadata")
        @book_chapter.descMetadata.should be_kind_of Datastream::ModsBookChapter
        @book_chapter.descMetadata.label.should == "MODS metadata"

        #Check for contentMetadata datastream
        @book_chapter.datastreams.keys.should include("contentMetadata")
        @book_chapter.contentMetadata.should be_kind_of Hyhull::Datastream::ContentMetadata

        #Check for the rightsMetadata datastream
        @book_chapter.datastreams.keys.should include("rightsMetadata")
        @book_chapter.rightsMetadata.should be_kind_of Hydra::Datastream::RightsMetadata
        @book_chapter.rightsMetadata.label.should == "Rights metadata"

        #Check for the properties datastream
        @book_chapter.datastreams.keys.should include("properties")
        @book_chapter.properties.should be_kind_of Hyhull::Datastream::WorkflowProperties
      end

      it "will support the required attributes of a Book resource" do
        attributes_hash = {
          # Standard Book type attributes
          "title" => "The title of the chapter",
          "person_name" => ["Author, The Main", "Editor, The"],
          "person_role_text" => ["Author", "Editor"],
          "description" => "Lorem ipsum dolor sit amet, consectetur adipisicing elit...",
          "subject_topic" => ["Topic 1", "Topic 2"],
          "related_item_print_issn" => "1234-54321",
          "related_item_electronic_issn" => "54321-09877",
          "related_item_isbn" => "233334343443",
          "related_item_doi" => "1.097/34354",
          "related_item_publication_date" => "c2009",
          "related_item_publisher" => "University press",
          "related_item_issuance" => "monographic",
          "related_item_place" => "Kingston Upon Hull, UK.",
          "series_title" => "The title of this series",
          "related_item_form" => "electronic",          
          "type_of_resource" => "text",
          "extent" => ["5 MB"],
          "related_item_physical_extent" => "vii, 322 p. ; 23 cm.",
          "related_web_url" => ["http://blacklight.hull.ac.uk/catalogue/1234"],
          "raw_object_url" => "http://hydra.hull.ac.uk/assets/hull-test:132a/content",
          # Book chapter specific
          "related_item_title" => "The publication title",
          "related_item_subtitle" => "Publication subtitle",
          "related_item_volume" => "1",
          "related_item_issue" => "1",
          "related_item_start_page" => "22",
          "related_item_end_page" => "35"
        }


        @book_chapter.update_attributes(attributes_hash)

        # Book related metadata
        @book_chapter.title.should == attributes_hash["title"]
        @book_chapter.person_name.should == attributes_hash["person_name"]
        @book_chapter.person_role_text.should == attributes_hash["person_role_text"]
        @book_chapter.description.should == attributes_hash["description"]
        @book_chapter.subject_topic.should == attributes_hash["subject_topic"]
        # Related item attrs
        @book_chapter.related_item_print_issn.should == attributes_hash["related_item_print_issn"]
        @book_chapter.related_item_electronic_issn.should == attributes_hash["related_item_electronic_issn"]
        @book_chapter.related_item_isbn.should == attributes_hash["related_item_isbn"]
        @book_chapter.related_item_doi.should == attributes_hash["related_item_doi"]
        @book_chapter.related_item_publication_date.should == attributes_hash["related_item_publication_date"]
        @book_chapter.related_item_publisher.should == attributes_hash["related_item_publisher"]
        @book_chapter.related_item_issuance.should == attributes_hash["related_item_issuance"]
        @book_chapter.related_item_place.should == attributes_hash["related_item_place"]
        @book_chapter.series_title.should == attributes_hash["series_title"]
        @book_chapter.related_item_form.should == attributes_hash["related_item_form"]
        @book_chapter.type_of_resource.should == attributes_hash["type_of_resource"]
        @book_chapter.extent.should== attributes_hash["extent"]
        @book_chapter.related_item_physical_extent.should == attributes_hash["related_item_physical_extent"]
        @book_chapter.related_web_url.should == attributes_hash["related_web_url"]
        @book_chapter.raw_object_url.should == attributes_hash["raw_object_url"]

        # Book specific chapter metadata
        @book_chapter.related_item_title.should == attributes_hash["related_item_title"]
        @book_chapter.related_item_subtitle.should == attributes_hash["related_item_subtitle"]
        @book_chapter.related_item_volume.should == attributes_hash["related_item_volume"]
        @book_chapter.related_item_issue.should == attributes_hash["related_item_issue"]
        @book_chapter.related_item_start_page.should == attributes_hash["related_item_start_page"]
        @book_chapter.related_item_end_page.should == attributes_hash["related_item_end_page"]
      end 

      it "should respond with validation errors when trying to save without the appropiate fields populated" do
          invalid_attributes_hash = {
            "title" => "",
            "genre" => "",
            "person_name" => [""],
            "person_role_text" => [""],
            "subject_topic" => [""],
            "language_code" => "",
            "language_text" => ""
          }

          @book_chapter.update_attributes( invalid_attributes_hash )

          # save should be false
          @book_chapter.save.should be_false

          # with 5 error messages
          @book_chapter.errors.messages.size.should == 3

          # errors...
          @book_chapter.errors.messages[:title].should == ["can't be blank"]
          @book_chapter.errors.messages[:genre].should == ["can't be blank"]
          @book_chapter.errors.messages[:subject_topic].should == ["is too short (minimum is 2 characters)"]
        end

        describe "assert_content_model" do
          it "should set the cModels" do
            @book_chapter.assert_content_model
            @book_chapter.genre = "Book chapter"
            @book_chapter.relationships(:has_model).should == ["info:fedora/hull-cModel:bookChapter", "info:fedora/hydra-cModel:compoundContent", "info:fedora/hydra-cModel:commonMetadata"]
          end    
        end

    
    context "non unique fields" do
      before(:each) do
        @attributes_hash = {
          "title" => "A thesis describing the...",
          "person_name" => ["Smith, John.", "Editor , A."],
          "person_role_text" => ["Author", "Editor"],
          "description" => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
          "subject_topic" => ["Subject of the matter"],
          "related_web_url" => ["http://SomeRelatedWebURL.org/Resource.id01"],
          "see_also" => ["LN02323", "PG23442"],
          "extent" => ["Filesize: 123KB", "Something else"],
          "rights" => ["Rights 1", "Rights 2"],
          "citation" => ["Cite as: This", "Cite as: that"]
        } 
        @book_chapter.update_attributes( @attributes_hash )        
      end
      it "should not overwrite the person_name, person_role_text, subject_topic, related_web_url, see_also, extent & rights if they are not within the attributes" do
        new_attributes_hash = { "title" => "A new title" }
        @book_chapter.update_attributes( new_attributes_hash )
        @book_chapter.title.should == new_attributes_hash["title"]
        @book_chapter.person_name.should ==  @attributes_hash["person_name"]
        @book_chapter.person_role_text.should == @attributes_hash["person_role_text"]
        @book_chapter.subject_topic.should == @attributes_hash["subject_topic"]
        @book_chapter.related_web_url.should == @attributes_hash["related_web_url"]
        @book_chapter.see_also.should == @attributes_hash["see_also"]
        @book_chapter.extent.should == @attributes_hash["extent"]
        @book_chapter.rights.should == @attributes_hash["rights"]
        @book_chapter.citation.should == @attributes_hash["citation"]
      end
    end 

        
    end   

end