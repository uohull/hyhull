# lib/hyhull/datastream/mods_structural_set.rb
# Datastream for the hyhull structural_set
module Hyhull
  module Datastream
    class ModsStructuralSet < ActiveFedora::OmDatastream

      set_terminology do |t|
        t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-4.xsd")
        t.title_info(:path=>"titleInfo") {
          t.main_title(:path=>"title", :label=>"title")
        } 
        t.title(:proxy=>[:mods, :title_info, :main_title]) 
        t.genre(:path=>'genre')
        t.type_of_resource(:path=>"typeOfResource")
        t.origin_info(:path=>'originInfo') {
          t.publisher
          t.date_issued(:path=>"dateIssued")
          t.date_valid(:path=>"dateValid", :attributes=>{:encoding=>'iso8601'})
        }
        t.language {
          t.lang_text(:path=>"languageTerm", :attributes=>{:type=>"text"})
          t.lang_code(:index_as=>[:facetable], :path=>"languageTerm", :attributes=>{:type=>"code"})
        }
        t.description(:path=>"abstract")
      
        t.identifier(:path => 'identifier',:attributes=>{:type=>"fedora"})

        t.location {
          t.primary_display(:path=>"url", :attributes=>{:access=>"object in context", :usage=>"primary display" })
        }
        t.record_info(:path=>"recordInfo") {
          t.record_creation_date(:path=>"recordCreationDate", :attributes=>{:encoding=>"w3cdtf"})
          t.record_change_date(:path=>"recordChangeDate", :attributes=>{:encoding=>"w3cdtf"})
        }
        t.resource_status(:path=>"note", :attributes=>{:type=>"admin"})

        # Proxies for terminologies   
        t.title(:proxy=>[:title_info, :main_title], :index_as=>[:searchable, :displayable])   
      end  
  
      def self.xml_template      
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.mods(:version=>"3.3", "xmlns:xlink"=>"http://www.w3.org/1999/xlink",
            "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
            "xmlns"=>"http://www.loc.gov/mods/v3",
            "xsi:schemaLocation"=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd") {
             xml.titleInfo {
               xml.title
             }
             xml.typeOfResource("text", :collection=>"yes") 
             xml.genre "Structural set"
             xml.abstract
             xml.originInfo {
               xml.publisher "The University of Hull"
               xml.dateIssued(Time.now.strftime("%Y-%m-%d"))
             }
             xml.identifier(:type=>"fedora")
             xml.location {
               xml.url(:access=>"raw object")
             } 
             xml.recordInfo {
               xml.recordContentSource "The University of Hull"
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
  end
end