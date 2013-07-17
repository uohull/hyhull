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
      t.doi(:path=>"identifier", :attributes=>{:type=>"doi"}, :index_as=>[:displayable])

      # Related Items 
      t.related_materials(:path=>"relatedItem", :attributes=>{:ID=>"relatedMaterials"})  {
        t.location {
          t.primary_display(:path=>"url", :attributes=>{:access=>"object in context", :usage=>"primary display" })
        }
      }

      t.see_also(:path=>"note", :attributes=>{:type=>"seeAlso"}, :index_as=>[:displayable])
      t.additional_notes(:path=>"note", :attributes=>{:type=>"additionalNotes"}, :index_as=>[:displayable])
      t.citation(:path=>"note", :attributes=>{:type=>"citation"}, :index_as=>[:displayable])
      t.software(:path=>"note", :attributes=>{:type=>"software"}, :index_as=>[:displayable])

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

      t.creator_organisation(:ref=>:organisation, :path=>'name[./xmlns:role/xmlns:roleTerm="Creator"]')
      t.creator_organisation_name(:proxy=>[:creator_organisation, :namePart], :index_as=>[:displayable, :facetable])


      #Proxies for terminologies 
      t.title(:proxy=>[:title_info, :main_title], :index_as=>[:displayable, :searchable, :sortable])
      t.version(:proxy=>[:title_info, :part_name], :index_as=>[:displayable])      
      t.subject_topic(:proxy=>[:subject, :topic], :index_as=>[:displayable, :facetable])
      t.subject_geographic(:proxy=>[:subject, :geographic])
      t.subject_temporal(:proxy=>[:subject, :temporal])
      t.location_coordinates(:proxy=>[:location, :cartographics, :coordinates])
      t.location_label(:proxy=>[:location, :display_label])
      t.location_coordinates_type(:proxy=>[:location, :coordinates_type])

      t.date_valid(:proxy=>[:origin_info, :date_valid], :index_as=>[:sortable, :displayable])
      t.date_issued(:proxy=>[:origin_info, :date_issued], :index_as=>[:sortable, :displayable])
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

      t.organisation_name(:proxy=>[:organisation, :namePart], :index_as=>[:displayable])
      t.organisation_role_text(:proxy=>[:organisation, :role, :text], :index_as=>[:displayable])
      t.organisation_role_code(:proxy=>[:organisation, :role, :code])        
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

    def qualification_name_terms
      ["PhD", "ClinPsyD", "MD", "PsyD", "MA" , "MEd", "MPhil", "MRes", "MSc" , "MTheol", "EdD" , "DBA", "BA", "BSc"]  
    end

    def qualification_level_terms
      ["Doctoral", "Masters", "Undergraduate"]
    end

    def dissertation_category_terms
      ["Blue", "Green", "Red"]
    end

    def department_names_list
      return DEPARTMENTS
    end

    def coordinates_types
      {
        "Path" => "LineString",
        "Polygon" => "Polygon",
        "Point" => "Point"
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

  def update_mods_content_metadata(content_asset, content_ds)
    content_size_bytes = eval "content_asset.#{content_ds}.size"
    begin
      self.physical_description.extent = self.class.bits_to_human_readable(content_size_bytes)
      self.physical_description.mime_type = eval "content_asset.#{content_ds}.mimeType"
      self.raw_object_url = "http://hydra.hull.ac.uk/assets/" + content_asset.pid + "/content"
      return true
    rescue Exception => e  
      logger.warn("#{self.class.to_s}.descMetadata does not define terminologies required for storing file metadata")
      return false
    end    
  end     

end