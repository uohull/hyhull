  class Datastream::ModsEtd < ActiveFedora::OmDatastream
    include Hyhull::Datastream::ModsMetadataBase 

    set_terminology do |t|
      t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd")

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

      t.language(:path=>"language"){
        t.lang_text(:path=>"languageTerm", :attributes=>{:type=>"text"})
        t.lang_code(:index_as=>[:facetable], :path=>"languageTerm", :attributes=>{:type=>"code"})
      }

      t.abstract(:index_as=>[:displayable, :searchable])

      t.subject(:attributes=>{:authority=>"UoH"}) {
        t.topic
      }
      t.topic_tag(:path=>"subject", :default_content_path=>"topic") 

      # This is a mods:name.  The underscore is purely to avoid namespace conflicts.
      t.name_ {
        t.type(:path => {:attribute=>"type"}, :namespace_prefix => nil)
        # this is a namepart
        t.namePart(:type=>:string, :label=>"generic name")
        t.role {
          t.text(:path=>"roleTerm",:attributes=>{:type=>"text"})
          t.code(:path=>"roleTerm",:attributes=>{:type=>"code"})
        }
      }

      # lookup :person, :first_name        
      t.person(:ref=>:name, :attributes=>{:type=>"personal"}, :index_as=>[:facetable])
      t.organisation(:ref=>:name, :attributes=>{:type=>"corporate"}, :index_as=>[:facetable])
      t.conference(:ref=>:name, :attributes=>{:type=>"conference"}, :index_as=>[:facetable])

      t.role {
        t.text(:path=>"roleTerm",:attributes=>{:type=>"text"})
        t.code(:path=>"roleTerm",:attributes=>{:type=>"code"})
      }
      #corporate_name/personal_name created to provide facets without an appended roleTerm
      t.corporate_name(:path=>"name", :attributes=>{:type=>"corporate"}) {
        t.part(:path=>"namePart",:index_as=>[:facetable])
      }
      t.personal_name(:path=>"name", :attributes=>{:type=>"personal"}) {
        t.part(:path=>"namePart",:index_as=>[:facetable])
      }

      t.genre(:path=>'genre', :index_as=>[:displayable, :facetable])
      t.type_of_resource(:path=>"typeOfResource")
      t.qualification_level(:path=>"note", :attributes=>{:type=>"qualificationLevel"}, :index_as=>[:displayable])
      t.qualification_name(:path=>"note", :attributes=>{:type=>"qualificationName"}, :index_as=>[:displayable])
      t.dissertation_category(:path=>"note", :attributes=>{:type=>"dissertationCategory"})
      t.resource_status(:path=>"note", :attributes=>{:type=>"admin"})
      t.origin_info(:path=>'originInfo') {
        t.date_issued(:path=>'dateIssued')
        t.date_valid(:path=>"dateValid", :attributes=>{:encoding=>'iso8601'})
        t.publisher
      }
      t.physical_description(:path=>"physicalDescription") {
        t.extent
        t.mime_type(:path=>"internetMediaType")
        t.digital_origin(:path=>"digitalOrigin")
      }
      t.rights(:path=>"accessCondition", :attributes=>{:type=>"useAndReproduction"})

      t.identifier(:path=>"identifier", :attributes=>{:type=>"fedora"})

      t.related_private_object(:path=>"relatedItem", :attributes=>{:type=>"privateObject"}) {
        t.private_object_id(:path=>"identifier", :attributes=>{:type=>"fedora"})
      }
      t.rights(:path=>"accessCondition", :attributes=>{:type=>"useAndReproduction"},  :index_as=>[:displayable])
        
      t.location_element(:path=>"location") {
        t.primary_display(:path=>"url", :attributes=>{:access=>"object in context", :usage=>"primary display" })
        t.raw_object(:path=>"url", :attributes=>{:access=>"raw object"})
      }

      t.grant_number(:path=>"identifier", :attributes=>{:type=>"grantNumber"})
      t.ethos_identifier(:path=>"identifier", :attributes=>{:type=>"ethos"})
      t.record_info(:path=>"recordInfo") {
        t.record_creation_date(:path=>"recordCreationDate", :attributes=>{:encoding=>"w3cdtf"})
        t.record_change_date(:path=>"recordChangeDate", :attributes=>{:encoding=>"w3cdtf"})
       }

     
      t.creator(:ref=>:person, :path=>'name[./xmlns:role/xmlns:roleTerm="creator"]' )
      t.creator_name(:proxy=>[:creator, :namePart], :index_as=>[:displayable, :facetable])
     # t.supervisor(:ref=>:name, :attributes=>{:type=>"personal"}, :path=>'name[./role/roleTerm="Supervisor"]')
     # t.sponsor(:ref=>:name, :attributes=>{:type=>"corporate"}, :path=>'name[./role/roleTerm="sponsor"]')


      #Proxies for terminologies 
      t.title(:proxy=>[:title_info, :main_title], :index_as=>[:displayable, :searchable, :sortable])      
      t.subject_topic(:proxy=>[:subject, :topic], :index_as=>[:displayable, :facetable])
      t.date_issued(:proxy=>[:origin_info, :date_issued], :index_as=>[:sortable, :displayable])
      t.date_valid(:proxy=>[:origin_info, :date_valid])
      t.publisher(:proxy=>[:origin_info, :publisher], :index_as=>[:displayable])
      t.extent(:proxy=>[:physical_description, :extent], :index_as=>[:displayable])
      t.mime_type(:proxy=>[:physical_description, :mime_type])
      t.digital_origin(:proxy=>[:physical_description, :digital_origin])
      t.primary_display_url(:proxy=>[:location_element, :primary_display])
      t.raw_object_url(:proxy=>[:location_element, :raw_object])
      t.record_creation_date(:proxy=>[:record_info, :record_creation_date])
      t.record_change_date(:proxy=>[:record_info, :record_change_date])
      t.language_text(:proxy=>[:language, :lang_text], :index_as=>[:displayable, :facetable])
      t.language_code(:proxy=>[:language, :lang_code])

      t.person_name(:proxy=>[:person, :namePart], :index_as=>[:displayable])
      t.person_role_text(:proxy=>[:person, :role, :text], :index_as=>[:displayable])
      t.person_role_code(:proxy=>[:person, :role, :code])

      t.organisation_name(:proxy=>[:organisation, :namePart], :index_as=>[:displayable])
      t.organisation_role_text(:proxy=>[:organisation, :role, :text], :index_as=>[:displayable])
      t.organisation_role_code(:proxy=>[:organisation, :role, :code])
  end
  
  # Generates an empty Mods Article (used when you call ModsArticle.new without passing in existing xml)
  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.mods(:version=>"3.3", "xmlns:xlink"=>"http://www.w3.org/1999/xlink",
        "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
        "xmlns"=>"http://www.loc.gov/mods/v3",
        "xsi:schemaLocation"=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd") {
        xml.titleInfo {
         xml.title
        }
        xml.name(:type=>"personal") {
          xml.namePart
          xml.role {
            xml.roleTerm("Creator", :type=>"text")
          }
        }
        xml.typeOfResource "text"
        xml.genre "Thesis or dissertation"
        xml.originInfo {
         xml.publisher
         xml.dateIssued
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
        xml.abstract
        xml.identifier(:type=>"fedora")
        xml.location {
         xml.url(:usage=>"primary display", :access=>"object in context")
         xml.url(:access=>"raw object")
        }
        xml.identifier(:type=>"grantNumber")
        xml.accessCondition(:type=>"useAndReproduction")
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

  def add_grant_number(values)
   ng_xml.search(self.grant_number.xpath, {oxns: "http://www.loc.gov/mods/v3"}).each do |n|
     n.remove
   end
   self.grant_number = values
  end

  def personal_creator_names
   ng_xml.xpath("//xmlns:name[@type='personal'][./xmlns:role/xmlns:roleTerm='Creator']/xmlns:namePart/text()").map { |creator| creator.to_s }
  end

  # Over-ride ModsMetadataMethods person_role_terms for mods-etd roles 
  def self.person_role_terms
  ["Creator", "Sponsor", "Supervisor"]
  end

  # Over-ride ModsMetadataMethods organisation_role_terms for mods-etd roles 
  def self.organisation_role_terms
    ["Sponsor"]
  end

end