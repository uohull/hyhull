module Hyhull::Datastream::BookTerminologies
  extend ActiveSupport::Concern

  # This module has been created to provide the MODS terminologies for Book type content
  #  Datastream::ModsBook and Datastream::ModsBookChapter 
  module ClassMethods

    # This adds the common MODS Book terminology 
    def add_book_terminology(t)    
        # Hyhull::Datastream::ModsMetadataBase provides these proxies specified by below...     
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
    
    end

    # This adds a related item terminology to the root of the passed in t (Terminology)
    # Book and Book chapters use a different relatedItem type, therefore this can be supplied. 
    def add_book_related_item_terminology(t, related_item_type)
        # Related item specific metadata
        # relatedItem type="otherVersion"
        t.related_item(:path=>'relatedItem', :attributes=>{:type=>related_item_type}) {
          t.publication_title_info(:path=>'titleInfo') {
            t.publication_main_title(:path=>'title')
            t.publication_subtitle(:path=>'subTitle')
          }
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
          t.part {
            t.volume(:path=>'detail', :attributes=>{:type=>'volume'}) {
              t.number
            }
            t.issue(:path=>'detail', :attributes=>{:type=>'issue'}) {
              t.number
            }
            t.pages(:path=>'extent', :attributes=>{:unit=>'page'}) {
              t.start
              t.end 
            }
            t.start_page(:proxy=>[:pages, :start])
            t.end_page(:proxy=>[:pages, :end])
          }

        }

      # These are typically used in Book Chapter metadata
      t.related_item_title(:proxy=>[:mods, :related_item, :publication_title_info, :publication_main_title], :index_as=>[:displayable])
      t.related_item_subtitle(:proxy=>[:mods, :related_item, :publication_title_info, :publication_subtitle], :index_as=>[:displayable])

      #originInfo for publication information - Generally Book resources
      t.related_item_date(:proxy=>[:mods, :related_item, :publication_origin_info, :publication_date_issued], :index_as=>[:displayable])
      t.related_item_publisher(:proxy=>[:mods, :related_item, :publication_origin_info, :publication_publisher], :index_as=>[:displayable])
      t.related_item_issuance(:proxy=>[:mods, :related_item, :publication_origin_info, :publication_issuance])
      t.related_item_place(:proxy=>[:mods, :related_item, :publication_origin_info, :publication_place, :placeTerm], :index_as=>[:displayable])
     
      t.related_item_volume(:proxy=>[:related_item, :part, :volume, :number], :index_as=>[:displayable] )
      t.related_item_issue(:proxy=>[:related_item, :part, :issue, :number], :index_as=>[:displayable] )
      t.related_item_start_page(:proxy=>[:related_item, :part, :pages, :start], :index_as=>[:displayable] )
      t.related_item_end_page(:proxy=>[:related_item, :part, :pages, :end], :index_as=>[:displayable] )

      # Related item proxies 
      t.related_item_print_issn(:proxy=>[:related_item, :issn_print], :index_as=>[:displayable] )
      t.related_item_electronic_issn(:proxy=>[:related_item, :issn_electronic], :index_as=>[:displayable] )
      t.related_item_isbn(:proxy=>[:related_item, :isbn], :index_as=>[:displayable])
      t.related_item_doi(:proxy=>[:related_item, :related_doi], :index_as=>[:displayable] )

      t.related_item_restriction(:proxy=>[:related_item, :note_restriction], :index_as=>[:displayable] )
      t.related_item_publications_note(:proxy=>[:related_item, :note_publications], :index_as=>[:displayable] )

      t.related_item_url(:proxy=>[:related_item, :location, :url], :index_as=>[:displayable])
      t.related_item_url_access(:proxy=>[:related_item, :location, :url, :access])
      t.related_item_url_display_label(:proxy=>[:related_item, :location, :url, :display_label], :index_as=>[:displayable])

      t.related_item_physical_extent(:proxy=>[:mods, :related_item, :related_item_physical_description, :extent], :index_as=>[:displayable])
      t.related_item_form(:proxy=>[:mods, :related_item, :related_item_physical_description, :form], :index_as=>[:displayable] )   

    end

  end
  
end