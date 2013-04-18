require 'spec_helper'

class TestClassOne < ActiveFedora::NokogiriDatastream
  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-3.xsd")

    t.title_info(:path=>"titleInfo") {
      t.main_title(:path=>"title", :label=>"title", :index_as=>[:facetable]) 
      t.language(:index_as=>[:facetable],:path=>{:attribute=>"lang"})
    } 
    t.author(:path=>"name", :attributes=>{:type=>"personal"}) {
      t.name(:path=>"namePart", :label=>"generic name")
      t.role {
        t.text(:part=>"roleTerm", :attributes=>{:type=>"text"})
      }
    }
    t.subject(:path=>"subject", :attributes=>{:authority=>"UoH"}) {
        t.topic( :index_as=>[:facetable])
    }

    t.abstract
    t.subject_topic(:proxy=>[:subject, :topic])
  end

  def self.xml_template
    builder = Nokogiri::XML::Document.new do |xml|
      xml.mods(:version=>"3.3", "xmlns:xlink"=>"http://www.w3.org/1999/xlink",
        "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
        "xmlns"=>"http://www.loc.gov/mods/v3",
        "xsi:schemaLocation"=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd") {
        xml.titleInfo {
         xml.title "Title goes here"
        }
        xml.name(:type=>"personal") {
          xml.namePart("Author goes here")
           xml.role {
             xml.roleTerm("creator",:type=>"text")
           }
        }
        xml.abstract
        xml.subject(:authority=>"UoH") {
          xml.topic "Subject topic goes here"
        }
      }
    end
    return builder.doc
  end

  def subject_topic=(value)
    ng_xml.search(self.subject_topic.xpath).each do |n|
      n.remove
    end
    self.subject_topic = values
  end


  # returns xpath from the term
  def subject_topics_xpath
    self.subject_topic.xpath
  end

  # attempts to use the term xpath to retrieve element
  def subject_topic_elements

    ng_xml.search(subject_topics_xpath, {oxns:"http://www.loc.gov/mods/v3"}).first.to_s
   
  end


  # hand crafted xpath
  def subject_topics_xpath_string
    "//xmlns:subject[@authority=\"UoH\"]/xmlns:topic"
  end

   # attempts to use the hand crafted xpath to retrieve element
  def subject_topic_elements_with_string
    ng_xml.search(subject_topics_xpath_string).first.to_s
  end

end

describe TestClassOne do

  before(:each) do
    #fixture - https://github.com/simonlamb/hyhull/blob/master/spec/fixtures/etd_descMetadata.xml
    @mods = fixture("hyhull/datastreams/etd_descMetadata.xml")    
    @mods = TestClassOne.from_xml(@mods)
  end

  describe "NokogiriDatastream" do

    it "term.xpath should return the expectd xpath statement" do
      @mods.subject_topics_xpath.should == "//oxns:subject[@authority=\"UoH\"]/oxns:topic"
    end
    it "should return elements using an xpath on the term name" do      
      @mods.subject_topic_elements.should == "<topic>Something quite complicated</topic>"
    end

    it "should return elements using a handcrafted xpath on the term name" do
      @mods.subject_topics_xpath_string.should == "//xmlns:subject[@authority=\"UoH\"]/xmlns:topic"
      @mods.subject_topic_elements_with_string.should == "<topic>Something quite complicated</topic>"
    end
  end

end
