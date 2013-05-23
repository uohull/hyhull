# encoding: utf-8
  
module Hyhull::ModelMethods
  extend ActiveSupport::Concern

  included do
    logger.info("Adding HyhullModelMethods to the Hydra model")

    #Store Hyhull workflow properties
    has_metadata name: "properties", label: "Workflow properties", type: Hyhull::Datastream::WorkflowProperties   
  end

  module ClassMethods
    #Overrides the pid_namespace method to use hull NS
    def pid_namespace
      "hull-cModel"
    end
  end

  # helper method to derive cmodel declaration from ruby model
  # standard pattern: pid_namespace:UketdObject
  # hulls pattern: pid_namespace:uketdObject 
  def cmodel
    model = self.class.to_s
    "info:fedora/hull-cModel:#{model[0,1].downcase + model[1..-1]}"
  end  

  # method for coordinating the addition of file metadata to self
  def add_file_metadata(file_asset, content_ds)

    # Now we should add content metadata if it is ...
    if self.respond_to?('add_content_metadata')
      resource_no = self.add_content_metadata(file_asset, content_ds)

      # resource 0 is the first resource to be added to the object - ModsMetadataMethods.add_mods_content_metadata
      if resource_no == 0 && self.descMetadata.respond_to?('update_mods_content_metadata')   
        self.descMetadata.update_mods_content_metadata(file_asset, content_ds)
      end 
    # if self doesn't contain contentMetadata, does it contain mods_content_metadata provision      
    elsif self.descMetadata.respond_to?('update_mods_content_metadata')   
      self.descMetadata.update_mods_content_metadata(file_asset, content_ds)
    end
  end


  # all rights reserved copyright statement 
  def all_rights_reserved_statement(person, year)
    unless ((person.nil? || person.empty?) || (year.nil? || year.empty?) )
      return "© #{year} #{person}. All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holder."
    end     
  end 

  #Quick utility method used to get long version of a date (YYYY-MM-DD) from short form (YYYY-MM) - Defaults 01 for unknowns
  def to_long_date(flexible_date)
    full_date = ""
    if flexible_date.match(/^\d{4}$/)
      full_date = flexible_date + "-01-01"
    elsif flexible_date.match(/^\d{4}-\d{2}$/)
      full_date = flexible_date +  "-01"
    elsif flexible_date.match(/^\d{4}-\d{2}-\d{2}$/)
      full_date = flexible_date
    end
    return full_date
  end

end