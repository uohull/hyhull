class Datastream::ModsBookChapter < ActiveFedora::OmDatastream
  include Hyhull::Datastream::ModsMetadataBase
  include Hyhull::Datastream::BookTerminologies

 # Setup a default terminology for this module     
  set_terminology do |t|
      t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd")

      add_book_terminology(t)
      # For the BookChapter mods metadata model we use the relatedItem type of 'host'
      add_book_related_item_terminology(t, 'host')
  end

  # Generates an empty Mods Book (used when you call ModsBook.new without passing in existing xml)
  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.mods(:version=>"3.4", "xmlns:xlink"=>"http://www.w3.org/1999/xlink",
      "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
      "xmlns"=>"http://www.loc.gov/mods/v3",
      "xsi:schemaLocation"=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd") {
        xml.titleInfo {
          xml.title
        }
        xml.name(:type=>"personal") {
          xml.namePart
          xml.role {
            xml.roleTerm(:type=>"text")
          }
        }
        xml.typeOfResource "text"
        xml.genre "Book chapter"
        xml.originInfo {
          xml.publisher
          xml.dateValid(:encoding=>"iso8601")
        }
        xml.language {                
          xml.languageTerm("English", :type=>"text")
          xml.languageTerm("eng", :authority=>"iso639-2b", :type=>"code")
        }
        xml.relatedItem(:type =>"host") {
          xml.physicalDescription {
            xml.form("print", :authority=>"marcform")
          }
        }
        xml.physicalDescription {
          xml.extent
          xml.mediaType
          xml.digitalOrigin "born digital"
        }
        xml.identifier(:type=>"fedora")
        xml.location {
          xml.url(:usage=>"primary display", :access=>"object in context")
          xml.url(:access=>"raw object")
        }
        xml.accessCondition(:type=>"useAndReproduction")
        xml.recordInfo {
          xml.recordContentSource self.default_institution_name 
          xml.recordCreationDate(Time.now.strftime("%Y-%m-%d"), :encoding=>"w3cdtf")
          xml.recordChangeDate(:encoding=>"w3cdtf")
          xml.languageOfCataloging {
            xml.languageTerm("eng", :authority=>"iso639-2b")  
          }
        }
      }
    end
    return builder.doc
  end


  # Overidden role terms for Book CM
  def self.person_role_terms
    ["Author", "Editor"]
  end

  def self.issuance_terms
    {
      "monographic" => "monographic",
      "single unit" => "single unit",
      "multipart monograph" => "multipart monograph",
      "continuing" => "continuing",
      "serial" => "serial",
      "integrating resource" => "integrating resource"
    }
  end

  def self.marc_form_terms
    {
      "Braille" => "braille",
      "Electronic" => "electronic",
      "Microfiche" => "microfiche",
      "Microfilm" => "microfilm",
      "Print" => "print",
      "Large print" => "large print"
    }
  end

end