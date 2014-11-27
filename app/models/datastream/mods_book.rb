class Datastream::ModsBook < ActiveFedora::OmDatastream
  include Hyhull::Datastream::ModsMetadataBase

   # Setup a default terminology for this module     
    set_terminology do |t|
      t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd")

      # See ModsMetadataBase for the available proxies specified by below...     
      add_title_terminology(t)
      add_language_terminology(t)
      add_subject_terminology(t)
      add_description_terminology(t)
      add_name_terminology(t)
      add_hyhull_terminology(t)
      add_converis_identifier_terminology(t)
      add_ref_uoa_terminology(t)
      add_peer_reviewed_terminology(t)

      # Related item - series information (book series)
      t.related_series_item(:path => 'relatedItem', :attributes =>{:type => 'series' }) {
        t.related_series_title_info(:path => "titleInfo") {
          t.related_series_main_title(:path => "title")
        }
      }

      # We may remove this...
      t.origin_info(:path=>'originInfo') {
        t.date_issued(:path=>'dateIssued')
        t.date_valid(:path=>'dateValid', :attributes=>{:encoding=>'iso8601'})
        t.publisher #(:index_as=>[:displayable])
      }

      t.doi(:path=>"identifier", :attributes=>{:type=>"doi"}, :index_as=>[:displayable])

      # Related Items 
      t.related_materials(:path=>"relatedItem", :attributes=>{:ID=>"relatedMaterials"})  {
        t.location {
          t.primary_display(:path=>"url", :attributes=>{:access=>"object in context", :usage=>"primary display" })
        }
      }

      # Related item specific metadata
      # relatedItem type="otherVersion"
      t.related_item(:path=>'relatedItem', :attributes=>{:type=>'otherVersion'}) {
        #originInfo modified for Books - place, issuance added
        t.publication_origin_info(:path=>'originInfo', :attributes=>{:eventType=>'publication'}) {
          t.publication_date_issued(:path=>'dateIssued', :attributes=>{:encoding=>'marc'})
          t.publication_publisher(:path=>'publisher')
          t.publication_place(:path =>'place') {
            t.placeTerm(:attributes=>{:type=>'text'})
          }
          t.publication_issuance(:path=>'issuance')
        }
        t.isbn(:path=>"identifier", :attributes=>{:type=>"isbn"})
        t.related_doi(:path=>'identifier', :attributes=>{:type=>'doi'})
        t.issn_print(:path=>'identifier', :attributes=>{:type=>'issn', :displayLabel=>'print'})
        t.issn_electronic(:path=>'identifier', :attributes=>{:type=>'issn', :displayLabel=>'electronic'})        

        t.note_restriction(:path=>'note', :attributes=>{:type=>'restriction'})
        t.note_publications(:path=>'note', :attributes=>{:type=>'publications'})
        t.location {
          t.url
          t.url {
            t.access(:path=>{:attribute=>"access"})
            t.display_label(:path=>{:attribute=>"displayLabel"})
          }       
        }
        t.related_item_physical_description(:path=>"physicalDescription") {
          t.extent
          # Use with marcform control list
          t.form(:attributes=>{:authority=>"marcform"})
        }
      }

      t.see_also(:path=>"note", :attributes=>{:type=>"seeAlso"}, :index_as=>[:displayable])
      t.citation(:path=>"note", :attributes=>{:type=>"citation"}, :index_as=>[:displayable])

      # Creator can be defined as a 'Creator/Photographer/Author...'
      t.creator(:ref=>:person, :path=>'name[./xmlns:role/xmlns:roleTerm="Author" or ./xmlns:role/xmlns:roleTerm="Editor"]')
      t.creator_name(:proxy=>[:creator, :namePart], :index_as=>[:symbol])
      # Contributor can be defined as a 'Sponsor/Supervisor...'
      t.contributor(:ref=>:person, :path=>'name[./xmlns:role/xmlns:roleTerm="Sponsor" or ./xmlns:role/xmlns:roleTerm="Supervisor"]')
      t.contributor_name(:proxy=>[:contributor, :namePart], :index_as=>[:displayable, :facetable])

      # Proxies     
      # Related item for series
      t.series_title(:proxy=>[:related_series_item, :related_series_title_info, :related_series_main_title], :index_as=>[:displayable])
   
      t.date_valid(:proxy=>[:origin_info, :date_valid], :index_as=>[:sortable, :displayable])
      t.date_issued(:proxy=>[:origin_info, :date_issued], :index_as=>[:sortable, :displayable])
      t.related_web_url(:proxy=>[:mods, :related_materials, :location, :primary_display], :index_as=>[:displayable])
      # Add :mods due to issue with matching two fields
      t.publisher(:proxy=>[:mods, :origin_info, :publisher], :index_as=>[:displayable])

      #originInfo for publication information - Generally Book resources
      t.publication_date(:proxy=>[:mods, :related_item, :publication_origin_info, :publication_date_issued], :index_as=>[:displayable])
      t.publication_publisher(:proxy=>[:mods, :related_item, :publication_origin_info, :publication_publisher], :index_as=>[:displayable])
      t.publication_issuance(:proxy=>[:mods, :related_item, :publication_origin_info, :publication_issuance])
      t.publication_place(:proxy=>[:mods, :related_item, :publication_origin_info, :publication_place, :placeTerm], :index_as=>[:displayable])
     
      # Related item proxies 
      t.related_item_print_issn(:proxy=>[:related_item, :issn_print], :index_as=>[:displayable] )
      t.related_item_electronic_issn(:proxy=>[:related_item, :issn_electronic], :index_as=>[:displayable] )
      t.related_item_isbn(:proxy=>[:related_item, :isbn], :index_as=>[:displayable])
      t.related_item_doi(:proxy=>[:related_item, :related_doi], :index_as=>[:displayable] )

      #t.related_item_volume(:proxy=>[:related_item, :part, :volume, :number], :index_as=>[:displayable])
      #t.related_item_start_page(:proxy=>[:related_item, :part, :pages, :start], :index_as=>[:displayable] )
      #t.related_item_end_page(:proxy=>[:related_item, :part, :pages, :end], :index_as=>[:displayable] )
      t.related_item_restriction(:proxy=>[:related_item, :note_restriction], :index_as=>[:displayable] )
      t.related_item_publications_note(:proxy=>[:related_item, :note_publications], :index_as=>[:displayable] )

      t.related_item_url(:proxy=>[:related_item, :location, :url], :index_as=>[:displayable])
      t.related_item_url_access(:proxy=>[:related_item, :location, :url, :access])
      t.related_item_url_display_label(:proxy=>[:related_item, :location, :url, :display_label], :index_as=>[:displayable])

      t.related_item_physical_extent(:proxy=>[:mods, :related_item, :related_item_physical_description, :extent], :index_as=>[:displayable])
      t.related_item_form(:proxy=>[:mods, :related_item, :related_item_physical_description, :form], :index_as=>[:displayable] )    
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
        xml.genre "Book"
        xml.originInfo {
          xml.publisher
          xml.dateValid(:encoding=>"iso8601")
        }
        xml.language {                
          xml.languageTerm("English", :type=>"text")
          xml.languageTerm("eng", :authority=>"iso639-2b", :type=>"code")
        }
        xml.relatedItem(:type =>"otherVersion") {
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