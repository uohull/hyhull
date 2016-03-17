class Datastream::ModsJournalArticle < ActiveFedora::OmDatastream
  include Hyhull::Datastream::ModsMetadataBase 

  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd")

    # Main fields title, authors, language etc...
    t.title_info(:path=>"titleInfo", :attributes => { :type => :none } ) {
      t.main_title(:path=>"title", :label=>"title", :ilndex_as=>[:facetable]) 
      t.language(:index_as=>[:facetable],:path=>{:attribute=>"lang"})
    }
    t.title_info_alternative(:path=>"titleInfo", :attributes=>{:type=>"alternative"}) {
      t.main_title_alternative(:path=>"title", :label=>"title_alternative", :index_as=>[:facetable]) 
      t.language(:index_as=>[:facetable],:path=>{:attribute=>"lang"})
    }

    t.language(:path=>"language") {
      t.lang_text(:path=>"languageTerm", :attributes=>{:type=>"text"})
      t.lang_code(:path=>"languageTerm", :attributes=>{:type=>"code"})
    }

    t.abstract(:index_as=>[:displayable, :searchable])

    t.subject(:attributes=>{:authority=>"UoH"}) {
      t.topic
    }
    t.topic_tag(:path=>"subject", :default_content_path=>"topic") 

    # This is a mods:name.  The underscore is purely to avoid name space conflicts.
    t.name_ {
      t.type(:path => {:attribute=>"type"}, :namespace_prefix => nil)
      # this is a namepart
      t.namePart(:type=>:string, :label=>"generic name")
      t.role {
        t.text(:path=>"roleTerm",:attributes=>{:type=>"text"})
        t.code(:path=>"roleTerm",:attributes=>{:type=>"code"})
      }
      t.affiliation(:index_as=>[:facetable, :searchable, :displayable], :label=>"affiliation")
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
      t.journal_origin_info(:path=>"originInfo") {
        t.journal_date_other(:path=>"dateOther", :label=>"dateOther", 
          :attributes=>{:type=>"accepted for publication", :encoding=>"w3cdtf"
        })
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
      t.note_publications(:path=>'note', :attributes=>{:type=>'publications'})

      t.location {
        t.url
        t.url {
          t.access(:path=>{:attribute=>"access"})
          t.display_label(:path=>{:attribute=>"displayLabel"})
        }       
      }
    }
    # Should be set to true/false
    t.peer_reviewed(:path=>'note', :attributes=>{:type=>'peerReviewed'}, :index_as=>[:displayable])
    # Unit of assessment used in REF items
    t.unit_of_assessment(:path=>"note",  :attributes=>{:type=>"unitOfAssessment"}, :index_as=>[:displayable])

    # REF exceptions
    t.ref_exception( :path => 'refException') {
      t.type(:path => {:attribute=>'type'}, :namespace_prefix => nil)
      t.display_label(:path=>{:attribute=>'displayLabel'}, :namespace_prefix => nil)
    }
    # ref - technical exception
    t.ref_exception_technical( :path => 'note', :attributes=>{:type=>'technical exception'} ) {
      t.display_label(
        :path => { :attribute => 'displayLabel'},
        :namespace_prefix => nil
      )
    }
    # ref - depositior exception
    t.ref_exception_deposit( :path => 'note', :attributes=>{:type=>'deposit exception'} ) {
      t.display_label(
        :path => { :attribute => 'displayLabel'},
        :namespace_prefix => nil
      )
    }
    # ref - access exception
    t.ref_exception_access( :path => 'note', :attributes=>{:type=>'access exception'} ) {
      t.display_label(
        :path => { :attribute => 'displayLabel'},
        :namespace_prefix => nil
      )
    }
    # ref - other exception
    t.ref_exception_other( :path => 'note', :attributes=>{:type=>'other exception'} ) {
      t.display_label(
        :path => { :attribute => 'displayLabel'},
        :namespace_prefix => nil
      )
    }
    # RIOXX - fields
    t.apc(:path=>'apc', attributes: { type: "rioxx" } )
    t.project(attributes: { type: "rioxx" } ) {
      t.project_funder_id(path: { attribute: "funderId"})
      t.project_funder_name(path: {attribute: "funderName"})
    }
    # t.free_to_read(path: "freeToRead", attributes: { type: "rioxx" } ) {
    #   t.free_to_read_start_date(path: { attribute: "startDate" })
    #   t.free_to_read_end_date(path: { attribute: "endDate"})
    # }
    # t.licence_url(path: "licenceUrl", attributes: { type: "rioxx"} ) {
    #   t.licence_start_date(path: { attribute: "startDate"})
    # }

    # Resource types 
    t.genre(:path=>'genre', :index_as=>[:displayable, :facetable])
    t.type_of_resource(:path=>"typeOfResource", :index_as=>[:displayable])
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

    # Converis identifiers 
    t.converis_related(:path=>"relatedItem", :attributes=>{:ID=>"converis", :type=>"original" }) {
      t.publication_id(:path=>"identifier", :attributes=>{:type=>"local", :displayLabel=>"iot_publication"})
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

    # These are generated to make easy solr fields for display
    t.creator(:ref=>:person, :path=>'name[./xmlns:role/xmlns:roleTerm="Author"]' )
    t.creator_name(:proxy=>[:creator, :namePart], :index_as=>[:symbol])

    #Proxies for terminologies
    # Removed due to issue with matching two fields
    #t.title(:proxy=>[:mods, :title_info, :main_title], :index_as=>[:displayable, :searchable, :sortable]) 
    t.subject_topic(:proxy=>[:subject, :topic], :index_as=>[:displayable, :facetable])
    t.date_issued(:proxy=>[:origin_info, :date_issued], :index_as=>[:sortable, :displayable])
    t.date_valid(:proxy=>[:origin_info, :date_valid])
    # Removed due to issue with matching two fields
    #t.publisher(:proxy=>[:origin_info, :publisher], :index_as=>[:displayable])
    t.extent(:proxy=>[:physical_description, :extent], :index_as=>[:displayable])
    t.mime_type(:proxy=>[:physical_description, :mime_type])
    t.digital_origin(:proxy=>[:physical_description, :digital_origin])
    t.primary_display_url(:proxy=>[:mods, :location_element, :primary_display])
    t.raw_object_url(:proxy=>[:mods, :location_element, :raw_object])
    t.record_creation_date(:proxy=>[:record_info, :record_creation_date])
    t.record_change_date(:proxy=>[:record_info, :record_change_date])
    t.language_text(:proxy=>[:language, :lang_text], :index_as=>[:displayable, :facetable])
    t.language_code(:proxy=>[:language, :lang_code], :index_as=>[:displayable])

    t.person_name(:proxy=>[:person, :namePart], :index_as=>[:displayable])
    t.person_role_text(:proxy=>[:person, :role, :text], :index_as=>[:displayable])
    t.person_role_code(:proxy=>[:person, :role, :code])
    t.person_affiliation(:proxy=>[:person, :affiliation], :index_as=>[:displayable, :searchable])

    t.organisation_name(:proxy=>[:organisation, :namePart], :index_as=>[:displayable])
    t.organisation_role_text(:proxy=>[:organisation, :role, :text], :index_as=>[:displayable])
    t.organisation_role_code(:proxy=>[:organisation, :role, :code])

    # Journal proxies 
    t.journal_title(:proxy=>[:journal, :journal_title_info, :journal_main_title], :index_as=>[:displayable] )
    t.journal_date_other(:proxy=>[:journal, :journal_origin_info, :journal_date_other], :index_as=>[:displayable])
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
    t.journal_publications_note(:proxy=>[:journal, :note_publications], :index_as=>[:displayable] )

    t.journal_url(:proxy=>[:journal, :location, :url], :index_as=>[:displayable])
    t.journal_url_access(:proxy=>[:journal, :location, :url, :access])
    t.journal_url_display_label(:proxy=>[:journal, :location, :url, :display_label], :index_as=>[:displayable])

    # Converis
    t.converis_publication_id(:proxy=>[:converis_related, :publication_id], :index_as =>[:searchable])

    # RIOXX/REF
    t.project_funder_id(:path => "project_funder_id", :proxy=>[:project, :project_funder_id])
    t.project_funder_name(:path => "project_funder_name", :proxy=>[:project, :project_funder_name])
    # t.free_to_read_start_date(:proxy=>[:free_to_read, :free_to_read_start_date])
    # t.free_to_read_end_date(:proxy=>[:free_to_read, :free_to_read_end_date])
    # t.licence_start_date(:proxy=>[:licence_url, :licence_start_date])

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
          xml.affiliation
        }
        xml.genre "Journal article"
        xml.language {
         xml.languageTerm("English", :type=>"text")
         xml.languageTerm("eng", :authority=>"iso639-2b", :type=>"code")
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
        xml.originInfo {
          xml.dateOther(:type=>"accepted for publication", 
            :encoding=>"w3cdtf")
        }
        xml.identifier(:type=>"issn", :displayLabel=>"print")
        xml.identifier(:type=>"issn", :displayLabel=>"electronic")
        xml.identifier(:type=>"doi")
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
          xml.recordContentSource self.default_institution_name 
          xml.recordCreationDate(Time.now.strftime("%Y-%m-%d"), :encoding=>"w3cdtf")
          xml.recordChangeDate(:encoding=>"w3cdtf")
          xml.languageOfCataloging {
            xml.languageTerm(:authority=>"iso639-2b")  
          }
        }
      }
    end
    return builder.doc
  end

  def add_names(names, roles, type, affiliations)
    if type == "person"
      xpath_type = "personal"
    elsif type == "organisation"
      xpath_type = "corporate"
    elsif type == "conference"
      xpath_type = "conference"
    end  
   
    ng_xml.search("//xmlns:name[@type=\"#{xpath_type}\"]").each do |n|
      n.remove
    end

    names.each_with_index do |name, index|    
      eval "self.#{type}(#{index}).namePart = name"
      eval "self.#{type}(#{index}).role.text = roles[index]"
      eval "self.#{type}(#{index}).affiliation = affiliations[index]"
    end
  end

  def add_journal_urls(url_list, url_access_list, url_display_label_list)
    begin 
      self.ng_xml.search(
        self.journal.location.url.xpath, { oxns: "http://www.loc.gov/mods/v3" }
        ).each do |n|
        n.remove
      end
   
      # Create the url elements
      self.journal.location.url = url_list

      # For each of the url elements, add the access amd display label
      url_list.each_with_index do |url, i|
        self.journal.location.url(i).access = url_access_list[i]
        self.journal.location.url(i).display_label = url_display_label_list[i] 
      end
    rescue
      logger.error "Problem adding journal urls to xml"
    end
  end

  def add_ref_exception(ref_exception_data)
    
    if (ref_exception_data.downcase == "none") 
      # default all ref exception types
      self.ref_exception_technical = false
      self.ref_exception_technical.display_label = nil

      self.ref_exception_deposit = false
      self.ref_exception_deposit.display_label = nil

      self.ref_exception_access = false
      self.ref_exception_access.display_label = nil

      self.ref_exception_other = false
      self.ref_exception_other.display_label = nil

    else

      # default all ref exception types
      self.ref_exception_technical = false
      self.ref_exception_technical.display_label = nil

      self.ref_exception_deposit = false
      self.ref_exception_deposit.display_label = nil

      self.ref_exception_access = false
      self.ref_exception_access.display_label = nil

      self.ref_exception_other = false
      self.ref_exception_other.display_label = nil

      # get exception properties
      list_of_values_technical = Property.select_by_property_type_name(
                                   "REF-EXCEPTION-TECHNICAL", false
                                 ).map(&:value)

      list_of_values_deposit = Property.select_by_property_type_name(
                                 "REF-EXCEPTION-DEPOSIT", false
                               ).map(&:value)

      list_of_values_access = Property.select_by_property_type_name(
                                "REF-EXCEPTION-ACCESS", false
                              ).map(&:value)

      # technical exception
      if list_of_values_technical.include? ref_exception_data
        self.ref_exception_technical = true
        self.ref_exception_technical.display_label = ref_exception_data
      # deposit exception
      elsif list_of_values_deposit.include? ref_exception_data
        self.ref_exception_deposit = true
        self.ref_exception_deposit.display_label = ref_exception_data   
      # access exception
      elsif list_of_values_access.include? ref_exception_data
        self.ref_exception_access = true
        self.ref_exception_access.display_label = ref_exception_data
      # other exception
      else
        self.ref_exception_other = true
        self.ref_exception_other.display_label = ref_exception_data
      end

    end

    # remove refException
    ng_xml.search("//xmlns:refException").each do |n|
      n.remove
    end

  end  

   # Over-ride ModsMetadataMethods person_role_terms for mods-etd roles 
  def self.person_role_terms
    ["Author", "Contributor"]
  end   

  def self.person_affiliation_terms
   #Get list of departments from Properties DB Table to be used for Jounal Article Person Affiliation
   #beacause they are properties in the DB, they can be edited within Hydra admin
   [["University of Hull"]] + [[""]] + 
   Property.select_by_property_type_name("JOURNAL-ARTICLE-AFFILIATION-FACULTY-ARTS", false).map(&:name) + 
   [[""]] + Property.select_by_property_type_name("JOURNAL-ARTICLE-AFFILIATION-FACULTY-SCI", false).map(&:name) + 
   [[""]] + Property.select_by_property_type_name("JOURNAL-ARTICLE-AFFILIATION-FACULTY-EDUCATION", false).map(&:name) + 
   [[""]] + Property.select_by_property_type_name("JOURNAL-ARTICLE-AFFILIATION-FACULTY-HEALTH", false).map(&:name) + 
   [[""]] + Property.select_by_property_type_name("JOURNAL-ARTICLE-AFFILIATION-FACULTY-BUSINESS-SCHOOL", false).map(&:name)
  end   

end