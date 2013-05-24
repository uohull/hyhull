# encoding: utf-8
  
module Hyhull::ModelMethods
  extend ActiveSupport::Concern

  included do
    logger.info("Adding HyhullModelMethods to the Hydra model")

    before_save :apply_dublin_core_metadata 

    # Store Hyhull workflow properties
    has_metadata name: "properties", label: "Workflow properties", type: Hyhull::Datastream::WorkflowProperties   
  
    # Reference the standard Fedora DC for storing simple metadata
    has_metadata name: "DC", label: "Dublin Core Record for this object", type: Hyhull::Datastream::DublinCore
    delegate :dc_title, to: "DC", at: [:title], unique: true
    delegate :dc_genre, to: "DC", at: [:genre], unique: true
    delegate :dc_date, to: "DC", at: [:date], unique: true

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

  # Apply basic metadata to the DC datastream, if the attributes exist on the object
  def apply_dublin_core_metadata
    self.dc_title = if self.respond_to? "title" then self.title end
    self.dc_genre = if self.respond_to? "genre" then self.genre end
    self.dc_date = if self.respond_to? "date_issued" then self.date_issued elsif self.respond_to? "date_valid" then self.date_valid end 
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