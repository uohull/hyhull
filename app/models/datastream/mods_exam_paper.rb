class Datastream::ModsExamPaper < ActiveFedora::OmDatastream
  include Hyhull::Datastream::ModsMetadataBase 

  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd")

    # Main fields title, authors, language etc...

    t.title_info(:path=>"titleInfo") {
      t.main_title(:path=>"title", :label=>"title", :index_as=>[:facetable]) 
    } 
   
    t.language(:path=>"language"){
      t.lang_text(:path=>"languageTerm", :attributes=>{:type=>"text"})
      t.lang_code(:index_as=>[:facetable], :path=>"languageTerm", :attributes=>{:type=>"code"})
    }
   
    t.subject(:attributes=>{:authority=>"UoH"}) {
      t.topic
    }
    t.topic_tag(:path=>"subject", :default_content_path=>"topic") 

   # This is a mods:name.  The underscore is purely to avoid namespace conflicts.
    t.name_ {
      t.type(:path => {:attribute=>"type"}, :namespace_prefix => nil)
      # this is a namepart
      t.namePart(:type=>:string)
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

    # Model specifics exam paper related information
    t.exam_level(:path=>"note", :attributes=>{:type=>"examinationLevel"}, :index_as=>[:displayable])
    t.additional_notes(:path=>"note", :attributes=>{:type=>"additionalNotes"}, :index_as=>[:displayable])    

    t.module(:path=>"relatedItem", :attributes=>{:ID=>"module"}) {
      t.name(:path=>"identifier", :attributes=>{:type=>"moduleName"})
      t.code(:path=>"identifier", :attributes=>{:type=>"moduleCode"})
      t.combined_display(:path=>"note", :attributes=>{:type=>"moduleDisplay"})
    }

    # Resource types 
    t.genre(:path=>'genre', :index_as=>[:displayable, :facetable])
    t.type_of_resource(:path=>"typeOfResource")
    t.resource_status(:path=>"note", :attributes=>{:type=>"admin"}, :index_as=>[:displayable])
    t.origin_info(:path=>'originInfo') {
      t.date_issued(:path=>'dateIssued')
      t.date_valid(:path=>"dateValid", :attributes=>{:encoding=>'iso8601'})
      t.publisher
    }

    # Rights and identifiers
    t.rights(:path=>"accessCondition", :attributes=>{:type=>"useAndReproduction"}, :index_as=>[:displayable])
    t.identifier(:attributes=>{:type=>"fedora"})
    t.related_private_object(:path=>"relatedItem", :attributes=>{:type=>"privateObject"}) {
      t.private_object_id(:path=>"identifier", :attributes=>{:type=>"fedora"})
    }

    # General cataloguing fields
    t.physical_description(:path=>"physicalDescription") {
      t.extent
      t.mime_type(:path=>"internetMediaType")
      t.digital_origin(:path=>"digitalOrigin")
    }
    t.location_element(:path=>"location") {
      t.primary_display(:path=>"url", :attributes=>{:access=>"object in context", :usage=>"primary display" })
      t.raw_object(:path=>"url", :attributes=>{:access=>"raw object"})
    }
    t.record_info(:path=>"recordInfo") {
      t.record_creation_date(:path=>"recordCreationDate", :attributes=>{:encoding=>"w3cdtf"})
      t.record_change_date(:path=>"recordChangeDate", :attributes=>{:encoding=>"w3cdtf"})
    }

    #Proxies for terminologies 
    t.title(:proxy=>[:title_info, :main_title], :index_as=>[:stored_searchable])      
    t.subject_topic(:proxy=>[:subject, :topic], :index_as=>[:displayable, :facetable])
    t.date_issued(:proxy=>[:origin_info, :date_issued], :index_as=>[:sortable, :displayable])
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

    t.module_name(:proxy=>[:module,:name])
    t.module_code(:proxy=>[:module, :code], :index_as=>[:facetable])
    t.module_display(:proxy=>[:module, :combined_display], :index_as=>[:displayable, :facetable])
    t.department_name(:proxy=>[:organisation, :namePart], :index_as=>[:displayable, :facetable])

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
        xml.name(:type=>"corporate") {
          xml.namePart
          xml.role {
            xml.roleTerm("Creator", :type=>"text")
          }
        }
        xml.typeOfResource "text"
        xml.genre "Examination paper"
        xml.originInfo {
          xml.publisher self.default_institution_name 
          xml.dateIssued
        }
        xml.language {                
          xml.languageTerm("English", :type=>"text")
          xml.languageTerm("eng", :authority=>"iso639-2b", :type=>"code")
        }
        xml.note(:type=>"examinationLevel")
        xml.note(:type=>"additionalNotes")
        xml.physicalDescription {
          xml.extent
          xml.mediaType
          xml.digitalOrigin "born digital"
        }
        xml.identifier(:type=>"fedora")
        xml.relatedItem(:ID=>"module") {
          xml.identifier(:type=>"moduleCode")
          xml.note(:type=>"moduleDisplay")
        }
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

  def add_modules(module_codes, module_names, module_display)
    # Remove the existing modules
    ng_xml.search(self.module.xpath, {oxns: "http://www.loc.gov/mods/v3"}).each do |n|
      n.remove
    end
    # Add the new ones...
    module_codes.each_with_index do |module_code, index|
      self.module(index).code = module_code
      self.module(index).name = module_names[index]
      self.module(index).combined_display = module_display[index]
    end
  end  

end