class Datastream::ModsJournalArticle < ActiveFedora::OmDatastream
  include Hyhull::ModsMetadataMethods 

  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd")

    # Main fields title, authors, language etc...
    t.title_info(:path=>"titleInfo") {
      t.main_title(:path=>"title", :label=>"title", :index_as=>[:facetable]) 
      t.language(:index_as=>[:facetable],:path=>{:attribute=>"lang"})
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

    # Journal article specific metadata
    # relatedItem type="otherVersion"
    t.journal(:path=>'relatedItem', :attributes=>{:type=>'otherVersion'}) {
      t.journal_title_info(:path=>"titleInfo") {
        t.journal_main_title(:path=>"title", :label=>"title")
      }
      t.origin_info(:path=>"originInfo") {
        t.publisher
        t.date_issued(:path=>"dateIssued")
      }
      t.issn_print(:path=>'identifier', :attributes=>{:type=>'issn', :displayLabel=>'print'})
      t.issn_electronic(:path=>'identifier', :attributes=>{:type=>'issn', :displayLabel=>'electronic'})
      t.doi(:path=>'identifier', :attributes=>{:type=>'doi'})
      t.part {
        t.volume(:path=>'detail', :attributes=>{:type=>'volume'}) {
          t.number
        }
        t.issue(:path=>'detail', :attributes=>{:type=>'issue'}) {
          t.number
        }
        t.pages(:path=>'extent', :attributes=>{:unit=>'pages'}) {
          t.start
          t.end 
        }
        t.start_page(:proxy=>[:pages, :start])
        t.end_page(:proxy=>[:pages, :end])
        t.publication_date(:path=>"date")
      }
      t.note_restriction(:path=>'note', :attributes=>{:type=>'restriction'})
    }
    # Should be set to true/false
    t.peer_reviewed(:path=>'note', :attributes=>{:type=>'peerReviewed'})

    # Resource types 
    t.genre(:path=>'genre', :index_as=>[:displayable, :facetable])
    t.type_of_resource(:path=>"typeOfResource")
    t.resource_status(:path=>"note", :attributes=>{:type=>"admin"})
    t.origin_info(:path=>'originInfo') {
      t.date_issued(:path=>'dateIssued')
      t.date_valid(:path=>"dateValid", :attributes=>{:encoding=>'iso8601'})
      t.publisher
    }

    # Rights and identifiers
    t.rights(:path=>"accessCondition", :attributes=>{:type=>"useAndReproduction"})
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

     # t.supervisor(:ref=>:name, :attributes=>{:type=>"personal"}, :path=>'name[./role/roleTerm="Supervisor"]')
     # t.sponsor(:ref=>:name, :attributes=>{:type=>"corporate"}, :path=>'name[./role/roleTerm="sponsor"]')

    #Proxies for terminologies 
    t.title(:proxy=>[:mods, :title_info, :main_title], :index_as=>[:displayable, :searchable, :sortable]) 
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

    # Journal proxies 
    t.journal_title(:proxy=>[:journal, :journal_title_info, :journal_main_title], :index_as=>[:displayable] )
    t.journal_publisher(:proxy=>[:journal, :origin_info, :publisher], :index_as=>[:displayable] )
    t.journal_publication_date(:proxy=>[:journal, :part, :publication_date], :index_as=>[:displayable, :sortable] )
    t.journal_print_issn(:proxy=>[:journal, :issn_print], :index_as=>[:displayable] )
    t.journal_electronic_issn(:proxy=>[:journal, :issn_electronic], :index_as=>[:displayable] )
    t.journal_article_doi(:proxy=>[:journal, :doi], :index_as=>[:displayable] )

    t.journal_volume(:proxy=>[:journal, :part, :volume, :number], :index_as=>[:displayable])
    t.journal_issue(:proxy=>[:journal, :part, :issue, :number], :index_as=>[:displayable] )
    t.journal_start_page(:proxy=>[:journal, :part, :pages, :start], :index_as=>[:displayable] )
    t.journal_end_page(:proxy=>[:journal, :part, :pages, :end], :index_as=>[:displayable] )
    t.journal_article_restriction(:proxy=>[:journal, :note_restriction], :index_as=>[:displayable] )

  end
  

  # Generates an empty Mods Article (used when you call ModsArticle.new without passing in existing xml)
  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.mods(:version=>"3.4", "xmlns:xlink"=>"http://www.w3.org/1999/xlink",
         "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
         "xmlns"=>"http://www.loc.gov/mods/v3",
         "xsi:schemaLocation"=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd") {
           xml.titleInfo(:lang=>"") {
             xml.title
           }
           xml.name(:type=>"personal") {
             xml.namePart
             xml.role {
               xml.roleTerm(:type=>"text")
             }
           }
           xml.genre
           xml.language {
             xml.languageTerm(:type=>"text")
             xml.languageTerm(:authority=>"iso639-2b", :type=>"code")
           }
           xml.abstract
           xml.subject(:authority=>"UoH") {
             xml.topic
           }
           xml.identifier(:type=>"fedora")
           xml.relatedItem(:type=>"otherVersion") {
             xml.titleInfo {
               xml.title
             }
             xml.issn_print(:path=>"identifier", :type=>"issn", :displayLabel=>"print")
             xml.issn_electronic(:path=>"identifier", :type=>"issn", :displayLabel=>"electronic")
             xml.doi(:path=>"identifier", :type=>"doi")
             xml.part {
               xml.detail(:type=>"volume") {
                 xml.number
               }
               xml.detail(:type=>"issue") {
                 xml.number
               }
               xml.extent(:unit=>"pages") {
                 xml.start
                 xml.end
               }
               xml.date
             }
           }
           xml.location {
             xml.url(:usage=>"primary display", :access=>"object in context")
             xml.url(:access=>"raw object")
           }           
           xml.originInfo {
             xml.publisher
             xml.dateIssued
           }
           xml.physicalDescription {
             xml.extent
             xml.internetMediaType
             xml.digitalOrigin 
           }
           xml.accessCondition(:type=>"useAndReproduction")
           xml.recordInfo {
             xml.recordContentSource
             xml.recordCreationDate(:encoding=>"w3cdtf")
             xml.recordChangeDate(:encoding=>"w3cdtf")
             xml.languageOfCataloging {
               xml.languageTerm(:authority=>"iso639-2b")  
             }
           }
      }
    end
    return builder.doc
  end 

   # Over-ride ModsMetadataMethods person_role_terms for mods-etd roles 
  def self.person_role_terms
    ["Author"]
  end   

end