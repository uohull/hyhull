# encoding: utf-8
# spec/models/book_spec.rb
require 'spec_helper'

describe Book do
  
  context "original spec" do
    before(:each) do
      # Create a new Generic Content object for the tests... 
      @book = Book.new
    end

    it "should have the specified datastreams" do
      #Check for descMetadata datastream
      @book.datastreams.keys.should include("descMetadata")
      @book.descMetadata.should be_kind_of Datastream::ModsBook
      @book.descMetadata.label.should == "MODS metadata"

      #Check for contentMetadata datastream
      @book.datastreams.keys.should include("contentMetadata")
      @book.contentMetadata.should be_kind_of Hyhull::Datastream::ContentMetadata

      #Check for the rightsMetadata datastream
      @book.datastreams.keys.should include("rightsMetadata")
      @book.rightsMetadata.should be_kind_of Hydra::Datastream::RightsMetadata
      @book.rightsMetadata.label.should == "Rights metadata"

      #Check for the properties datastream
      @book.datastreams.keys.should include("properties")
      @book.properties.should be_kind_of Hyhull::Datastream::WorkflowProperties
    end

    it "will support the required attributes of a Book resource" do
      attributes_hash = {
        "title" => "The main title of this book",
        "subtitle" => "The subtitle of the book",
        "person_name" => ["Author, The Main", "Editor, The"],
        "person_role_text" => ["Author", "Editor"],
        "description" => "Lorem ipsum dolor sit amet, consectetur adipisicing elit...",
        "subject_topic" => ["Topic 1", "Topic 2"],
        "related_item_print_issn" => "1234-54321",
        "related_item_electronic_issn" => "54321-09877",
        "related_item_isbn" => "233334343443",
        "related_item_doi" => "1.097/34354",
        "publication_date" => "c2009",
        "publication_publisher" => "University press",
        "publication_issuance" => "monographic",
        "publication_place" => "Kingston Upon Hull, UK.",
        "series_title" => "The title of this series",
        "related_item_form" => "electronic",
        "type_of_resource" => "text",
        "extent" => ["5 MB"],
        "related_item_physical_extent" => "vii, 322 p. ; 23 cm.",
        "related_web_url" => ["http://blacklight.hull.ac.uk/catalogue/1234"],
        "raw_object_url" => "http://hydra.hull.ac.uk/assets/hull-test:132a/content"
      }

      @book.update_attributes(attributes_hash)

      @book.title.should == attributes_hash["title"]
      @book.subtitle.should == attributes_hash["subtitle"]
      @book.person_name.should == attributes_hash["person_name"]
      @book.person_role_text.should == attributes_hash["person_role_text"]
      @book.description.should == attributes_hash["description"]
      @book.subject_topic.should == attributes_hash["subject_topic"]
      # Related item attrs
      @book.related_item_print_issn.should == attributes_hash["related_item_print_issn"]
      @book.related_item_electronic_issn.should == attributes_hash["related_item_electronic_issn"]
      @book.related_item_isbn.should == attributes_hash["related_item_isbn"]
      @book.related_item_doi.should == attributes_hash["related_item_doi"]
      @book.publication_date.should == attributes_hash["publication_date"]
      @book.publication_publisher.should == attributes_hash["publication_publisher"]
      @book.publication_issuance.should == attributes_hash["publication_issuance"]
      @book.publication_place.should == attributes_hash["publication_place"]

      @book.series_title.should == attributes_hash["series_title"]
      @book.related_item_form.should == attributes_hash["related_item_form"]
      @book.type_of_resource.should == attributes_hash["type_of_resource"]
      @book.extent.should== attributes_hash["extent"]
      @book.related_item_physical_extent.should == attributes_hash["related_item_physical_extent"]
      @book.related_web_url.should == attributes_hash["related_web_url"]
      @book.genre.should == "Book" 
      @book.raw_object_url.should == attributes_hash["raw_object_url"]
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

      @book.update_attributes( invalid_attributes_hash )

      # save should be false
      @book.save.should be_false

      # with 5 error messages
      @book.errors.messages.size.should == 3

      # errors...
      @book.errors.messages[:title].should == ["can't be blank"]
      @book.errors.messages[:genre].should == ["can't be blank"]
      @book.errors.messages[:subject_topic].should == ["is too short (minimum is 2 characters)"]
    end

    describe "assert_content_model" do
      it "should set the cModels" do
        @book.assert_content_model
        @book.genre = "Book"
        @book.relationships(:has_model).should == ["info:fedora/hull-cModel:book", "info:fedora/hydra-cModel:compoundContent", "info:fedora/hydra-cModel:commonMetadata"]
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
        @book.update_attributes( @attributes_hash )        
      end
      it "should not overwrite the person_name, person_role_text, subject_topic, related_web_url, see_also, extent & rights if they are not within the attributes" do
        new_attributes_hash = { "title" => "A new title" }
        @book.update_attributes( new_attributes_hash )
        @book.title.should == new_attributes_hash["title"]
        @book.person_name.should ==  @attributes_hash["person_name"]
        @book.person_role_text.should == @attributes_hash["person_role_text"]
        @book.subject_topic.should == @attributes_hash["subject_topic"]
        @book.related_web_url.should == @attributes_hash["related_web_url"]
        @book.see_also.should == @attributes_hash["see_also"]
        @book.extent.should == @attributes_hash["extent"]
        @book.rights.should == @attributes_hash["rights"]
        @book.citation.should == @attributes_hash["citation"]
      end
    end 

   end

end

