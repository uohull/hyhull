class Datastream::ModsGenericContent < ActiveFedora::OmDatastream
  include Hyhull::ModsMetadataMethods 

  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd")

    # Main fields title, authors, language etc...

    t.title_info(:path=>"titleInfo") {
      t.main_title(:path=>"title", :label=>"title", :index_as=>[:facetable]) 
    } 
   
    t.language(:path=>"language") {
      t.lang_text(:path=>"languageTerm", :attributes=>{:type=>"text"})
      t.lang_code(:index_as=>[:facetable], :path=>"languageTerm", :attributes=>{:type=>"code"})
    }
   
    t.subject(:attributes=>{:authority=>"UoH"}) {
      t.topic
      t.temporal
      t.geographic
    }

    # Description is stored in the 'abstract' field 
    t.description(:path=>"abstract")

    # Subject element to store location/carts 
    t.location(:path=>"subject", :attributes=>{:ID=>"location"}) {
      t.display_label(:path=>{:attribute=>"displayLabel"}, :namespace_prefix => nil)
      t.coordinates_type(:path=>"topic")
      t.cartographics {
        t.coordinates
      }
    }

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

    # lookup :person, :first_name        
    #t.department(:ref=>:name, :attributes=>{:type=>"corporate"}, :index_as=>[:facetable])
    #t.conference(:ref=>:name, :attributes=>{:type=>"conference"}, :index_as=>[:facetable])

    # Resource types 
    t.genre(:path=>'genre', :index_as=>[:displayable, :facetable])
    t.type_of_resource(:path=>"typeOfResource")
    t.resource_status(:path=>"note", :attributes=>{:type=>"admin"})
    t.origin_info(:path=>'originInfo') {
      t.date_issued(:path=>'dateIssued')
      t.date_valid(:path=>'dateValid', :attributes=>{:encoding=>'iso8601'})
      t.publisher
    }

    # Rights and identifiers
    t.rights(:path=>"accessCondition", :attributes=>{:type=>"useAndReproduction"})
    t.identifier(:attributes=>{:type=>"fedora"})
    t.related_private_object(:path=>"relatedItem", :attributes=>{:type=>"privateObject"}) {
      t.private_object_id(:path=>"identifier", :attributes=>{:type=>"fedora"})
    }

    # Related Items 
    t.related_materials(:path=>"relatedItem", :attributes=>{:ID=>"relatedMaterials"})  {
      t.location {
        t.primary_display(:path=>"url", :attributes=>{:access=>"object in context", :usage=>"primary display" })
      }
    }

    t.see_also(:path=>"note", :attributes=>{:type=>"seeAlso"})
    t.additional_notes(:path=>"note", :attributes=>{:type=>"additionalNotes"})

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

    t.creator(:ref=>:person, :path=>'name[./xmlns:role/xmlns:roleTerm="Photographer" or ./xmlns:role/xmlns:roleTerm="Creator" or ./xmlns:role/xmlns:roleTerm="Author"]')
    t.creator_name(:proxy=>[:creator, :namePart], :index_as=>[:displayable, :facetable])

    #Proxies for terminologies 
    t.title(:proxy=>[:title_info, :main_title], :index_as=>[:displayable, :searchable, :sortable])      
    t.subject_topic(:proxy=>[:subject, :topic], :index_as=>[:displayable, :facetable])
    t.subject_geographic(:proxy=>[:subject, :geographic])
    t.subject_temporal(:proxy=>[:subject, :temporal])
    t.location_coordinates(:proxy=>[:location, :cartographics, :coordinates])
    t.location_label(:proxy=>[:location, :display_label])
    t.location_coordinates_type(:proxy=>[:location, :coordinates_type])

    t.date_valid(:proxy=>[:origin_info, :date_valid], :index_as=>[:sortable, :displayable])
    t.related_web_url(:proxy=>[:related_materials, :location, :primary_display])
    t.publisher(:proxy=>[:origin_info, :publisher], :index_as=>[:displayable])
    t.extent(:proxy=>[:physical_description, :extent], :index_as=>[:displayable])
    t.mime_type(:proxy=>[:physical_description, :mime_type])
    t.digital_origin(:proxy=>[:physical_description, :digital_origin])
    
    # Removed due to issue with matching two fields
    #t.primary_display_url(:proxy=>[:location_element, :primary_display])
    #t.raw_object_url(:proxy=>[:location_element, :raw_object])
    
    t.record_creation_date(:proxy=>[:record_info, :record_creation_date])
    t.record_change_date(:proxy=>[:record_info, :record_change_date])
    t.language_text(:proxy=>[:language, :lang_text], :index_as=>[:displayable, :facetable])
    t.language_code(:proxy=>[:language, :lang_code])

    t.person_name(:proxy=>[:person, :namePart], :index_as=>[:displayable])
    t.person_role_text(:proxy=>[:person, :role, :text], :index_as=>[:displayable])
    t.person_role_code(:proxy=>[:person, :role, :code])


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
            xml.roleTerm(:type=>"text")
          }
        }
        xml.typeOfResource
        xml.genre
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