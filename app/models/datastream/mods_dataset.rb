class Datastream::ModsDataset < ActiveFedora::OmDatastream
  include Hyhull::Datastream::ModsMetadataBase 

  # Generates an empty Mods Article (used when you call ModsArticle.new without passing in existing xml)
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
        xml.typeOfResource "dataset"
        xml.genre "Dataset"
        xml.originInfo {
          xml.publisher
          xml.dateValid(:encoding=>"iso8601")
        }
        xml.language {                
          xml.languageTerm("English", :type=>"text")
          xml.languageTerm("eng", :authority=>"iso639-2b", :type=>"code")
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

end