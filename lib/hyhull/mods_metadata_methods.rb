# encoding: utf-8

module Hyhull::ModsMetadataMethods
  extend ActiveSupport::Concern

  included do
    logger.info("Adding Hyhull::ModsMetadataMethods to the model")
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