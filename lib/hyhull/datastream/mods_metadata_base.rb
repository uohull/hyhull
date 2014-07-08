# encoding: utf-8

module Hyhull::Datastream::ModsMetadataBase
  extend ActiveSupport::Concern

  included do
    logger.info("Adding Hyhull::ModsMetadataMethods to the model")

    # Setup a default terminology for this module     
    set_terminology do |t|
      t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd")

      # Main fields title, authors, language etc...

      t.title_info(:path=>"titleInfo") {
        t.main_title(:path=>"title", :label=>"title", :index_as=>[:facetable])
        t.part_name(:path=>"partName") 
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
      t.description(:path=>"abstract", :index_as=>[:displayable])

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
      t.type_of_resource(:path=>"typeOfResource", :index_as=>[:displayable])
      t.resource_status(:path=>"note", :attributes=>{:type=>"admin"}, :index_as=>[:displayable])
      t.origin_info(:path=>'originInfo') {
        t.date_issued(:path=>'dateIssued')
        t.date_valid(:path=>'dateValid', :attributes=>{:encoding=>'iso8601'})
        t.publisher #(:index_as=>[:displayable])
      }

      # Rights and identifiers
      t.rights(:path=>"accessCondition", :attributes=>{:type=>"useAndReproduction"}, :index_as=>[:displayable])
      t.identifier(:attributes=>{:type=>"fedora"})
      t.related_private_object(:path=>"relatedItem", :attributes=>{:type=>"privateObject"}) {
        t.private_object_id(:path=>"identifier", :attributes=>{:type=>"fedora"})
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
        t.related_item_title_info(:path=>"titleInfo") {
          t.related_item_main_title(:path=>"title", :label=>"title")
        }
        t.origin_info(:path=>"originInfo") {
          t.publisher
          t.date_issued(:path=>"dateIssued")
        }
        t.issn_print(:path=>'identifier', :attributes=>{:type=>'issn', :displayLabel=>'print'})
        t.issn_electronic(:path=>'identifier', :attributes=>{:type=>'issn', :displayLabel=>'electronic'})
        t.isbn(:path=>"identifier", :attributes=>{:type=>"isbn"})
        t.related_doi(:path=>'identifier', :attributes=>{:type=>'doi'})
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

      # Converis identifiers 
      t.converis_related(:path=>"relatedItem", :attributes=>{:ID=>"converis", :type=>"original" }) {
        t.publication_id(:path=>"identifier", :attributes=>{:type=>"local", :displayLabel=>"iot_publication"})
      }

      t.see_also(:path=>"note", :attributes=>{:type=>"seeAlso"}, :index_as=>[:displayable])
      t.additional_notes(:path=>"note", :attributes=>{:type=>"additionalNotes"}, :index_as=>[:displayable])
      t.citation(:path=>"note", :attributes=>{:type=>"citation"}, :index_as=>[:displayable])
      t.software(:path=>"note", :attributes=>{:type=>"software"}, :index_as=>[:displayable])
      # Unit of assessment used in REF items
      t.unit_of_assessment(:path=>"note",  :attributes=>{:type=>"unitOfAssessment"}, :index_as=>[:displayable])
      # Should be set to true/false
      t.peer_reviewed(:path=>'note', :attributes=>{:type=>'peerReviewed'}, :index_as=>[:displayable])

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

      # Creator can be defined as a 'Creator/Photographer/Author...'
      t.creator(:ref=>:person, :path=>'name[./xmlns:role/xmlns:roleTerm="Photographer" or ./xmlns:role/xmlns:roleTerm="Creator" or ./xmlns:role/xmlns:roleTerm="Author"]')
      t.creator_name(:proxy=>[:creator, :namePart], :index_as=>[:symbol])

      # Contributor can be defined as a 'Sponsor/Supervisor...'
      t.contributor(:ref=>:person, :path=>'name[./xmlns:role/xmlns:roleTerm="Sponsor" or ./xmlns:role/xmlns:roleTerm="Supervisor" or ./xmlns:role/xmlns:roleTerm="Editor"]')
      t.contributor_name(:proxy=>[:contributor, :namePart], :index_as=>[:displayable, :facetable])

      t.creator_organisation(:ref=>:organisation, :path=>'name[./xmlns:role/xmlns:roleTerm="Creator"]')
      t.creator_organisation_name(:proxy=>[:creator_organisation, :namePart], :index_as=>[:symbol])

      #Proxies for terminologies 
      # Added :mods due to issue with matching two fields
      t.title(:proxy=>[:mods, :title_info, :main_title], :index_as=>[:stored_searchable])
      t.version(:proxy=>[:title_info, :part_name], :index_as=>[:displayable])      
      t.subject_topic(:proxy=>[:subject, :topic], :index_as=>[:displayable, :facetable])
      t.subject_geographic(:proxy=>[:subject, :geographic], :index_as=>[:displayable])
      t.subject_temporal(:proxy=>[:subject, :temporal], :index_as=>[:displayable])
      t.location_coordinates(:proxy=>[:location, :cartographics, :coordinates], :index_as=>[:displayable])
      t.location_label(:proxy=>[:location, :display_label], :index_as=>[:displayable])
      t.location_coordinates_type(:proxy=>[:location, :coordinates_type], :index_as=>[:displayable])

      t.date_valid(:proxy=>[:origin_info, :date_valid], :index_as=>[:sortable, :displayable])
      t.date_issued(:proxy=>[:origin_info, :date_issued], :index_as=>[:sortable, :displayable])
      t.related_web_url(:proxy=>[:related_materials, :location, :primary_display], :index_as=>[:displayable])
      # Add :mods due to issue with matching two fields
      t.publisher(:proxy=>[:mods, :origin_info, :publisher], :index_as=>[:displayable])
      t.extent(:proxy=>[:physical_description, :extent], :index_as=>[:displayable])
      t.mime_type(:proxy=>[:physical_description, :mime_type], :index_as=>[:displayable])
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

      t.organisation_name(:proxy=>[:organisation, :namePart], :index_as=>[:displayable])
      t.organisation_role_text(:proxy=>[:organisation, :role, :text], :index_as=>[:displayable])
      t.organisation_role_code(:proxy=>[:organisation, :role, :code]) 

      # Related item proxies 
      t.related_item_title(:proxy=>[:related_item, :related_item_title_info, :related_item_main_title], :index_as=>[:displayable] )
      t.related_item_publisher(:proxy=>[:related_item, :origin_info, :publisher], :index_as=>[:displayable] )
      t.related_item_publication_date(:proxy=>[:related_item, :part, :publication_date], :index_as=>[:displayable, :sortable] )
      t.related_item_print_issn(:proxy=>[:related_item, :issn_print], :index_as=>[:displayable] )
      t.related_item_electronic_issn(:proxy=>[:related_item, :issn_electronic], :index_as=>[:displayable] )
      t.related_item_isbn(:proxy=>[:related_item, :isbn], :index_as=>[:displayable])
      t.related_item_doi(:proxy=>[:related_item, :related_doi], :index_as=>[:displayable] )

      t.related_item_volume(:proxy=>[:related_item, :part, :volume, :number], :index_as=>[:displayable])
      t.related_item_issue(:proxy=>[:related_item, :part, :issue, :number], :index_as=>[:displayable] )
      t.related_item_start_page(:proxy=>[:related_item, :part, :pages, :start], :index_as=>[:displayable] )
      t.related_item_end_page(:proxy=>[:related_item, :part, :pages, :end], :index_as=>[:displayable] )
      t.related_item_restriction(:proxy=>[:related_item, :note_restriction], :index_as=>[:displayable] )
      t.related_item_publications_note(:proxy=>[:related_item, :note_publications], :index_as=>[:displayable] )

      t.related_item_url(:proxy=>[:related_item, :location, :url], :index_as=>[:displayable])
      t.related_item_url_access(:proxy=>[:related_item, :location, :url, :access])
      t.related_item_url_display_label(:proxy=>[:related_item, :location, :url, :display_label], :index_as=>[:displayable])

      # Converis
      t.converis_publication_id(:proxy=>[:converis_related, :publication_id], :index_as =>[:searchable])       
    end

  end

  module ClassMethods
    #Overrides the pid_namespace method to use hull NS
    def person_relator_terms
      {
        "aut" => "Author",
        "cre" => "Creator",
        "edt" => "Editor",
        "phg" => "Photographer",  
        "mdl" => "Module leader",
        "spr" => "Sponsor",
        "sup" => "Supervisor"     
      }
    end

    def person_role_terms
      ["Author", "Creator", "Editor", "Photographer", "Module leader", "Sponsor", "Supervisor"]
    end

    def organisation_role_terms
      [ "Creator", "Host", "Sponsor"]
    end

    def coordinates_types
      {
        "Path" => "LineString",
        "Polygon" => "Polygon",
        "Point" => "Point"
      }
    end

    def url_access_terms
      {
        "preview" => "preview",
        "raw object" => "raw object",
        "object in context" => "object in context"
      }
    end

    # Returns a human readable filesize appropriate for the given number of bytes (ie. automatically chooses 'bytes','KB','MB','GB','TB')
    # Based on a bit of python code posted here: http://blogmag.net/blog/read/38/Print_human_readable_file_size
    # @param [Numeric] num file size in bits
    def bits_to_human_readable(num)
      ['bytes','KB','MB','GB','TB'].each do |x|
        if num < 1024.0
          return "#{num.to_i} #{x}"
        else
          num = num/1024.0
        end
      end
    end

    # all rights reserved copyright statement 
    # person can be a string or array of names...
    # "Simon Lamb", 2013
    # © 2013 Simon Lamb. All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holder
    #
    # ["Simon Lamb", "Richard Green"], 2013 
    # © 2013 Richard Green and Simon Lamb. All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holders
    def all_rights_reserved_statement(person, year)
      plural = ""
      unless ((person.nil? || person.empty?) || (year.nil? || year.empty?) )
        if person.kind_of? Array 
          plural = person.length > 1 ? "s" : ""
          person = person.map { |name|  name == person.first ? name : name == person.last ? " and #{name}" : ", #{name}" }.join("")
        end
        return "© #{year} #{person}. All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holder#{plural}."
      end     
    end 

    def default_institution_name 
      return DEFAULT_INSTITUTION_NAME.nil? ? "" : DEFAULT_INSTITUTION_NAME
    end

  end

  def add_subject_topic(values)
   self.ng_xml.search(self.subject_topic.xpath, {oxns: "http://www.loc.gov/mods/v3"}).each do |n|
     n.remove
   end
   self.subject(1).topic = values
  end

  def add_names(names, roles, type)
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
     end
  end

  # Uses CONTENT_LOCATION_URL_BASE configured in config/initializers/hyhull.rb
  # TODO Refactor the shared code in these methods 
  def update_mods_content_metadata(content_asset, content_ds)
    content_size_bytes = content_asset.datastreams[content_ds].size
    begin
      self.physical_description.extent = self.class.bits_to_human_readable(content_size_bytes)
      self.physical_description.mime_type = content_asset.datastreams[content_ds].mimeType
      self.location_element.raw_object = "#{CONTENT_LOCATION_URL_BASE}/assets/#{content_asset.pid}/#{content_ds}"
      return true
    rescue Exception => e  
      logger.warn("#{self.class.to_s}.descMetadata does not define terminologies required for storing file metadata")
      return false
    end    
  end 

  # Uses CONTENT_LOCATION_URL_BASE configured in config/initializers/hyhull.rb 
  # TODO Refactor the shared code in these methods 
  def update_mods_content_metadata_by_params(asset_id, asset_ds_id , size, mime_type)  
    begin
      self.physical_description.extent = self.class.bits_to_human_readable(size.to_i)
      self.physical_description.mime_type = mime_type
      self.location_element.raw_object = "#{CONTENT_LOCATION_URL_BASE}/assets/#{asset_id}/#{asset_ds_id}"
      return true
    rescue Exception => e  
      logger.warn("#{self.class.to_s}.descMetadata does not define terminologies required for storing file metadata")
      return false
    end    
  end

  # Returns a solr sortable_creator from the mods metadata
  # Note a solr sortable field cannot be multi-valued -Returning the first creator in array.
  def get_solr_sortable_creator
    solr_sortable_creator = ""

    begin
      solr_sortable_creator = self.creator_name.first unless self.creator_name.empty?
    rescue NoMethodError
      # creator_name does not exist for this mods datastream
    end

    return solr_sortable_creator
  end

  # Overrides to_solr to include a sortable creator name (if it exists)
  def to_solr(solr_doc = Hash.new)
    super(solr_doc)

    creator = get_solr_sortable_creator
    unless creator == ""
      solr_doc.merge!("creator_name_ssort" => creator )
    end
    solr_doc   
  end  

end