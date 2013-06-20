# encoding: utf-8
  
module Hyhull::ModelMethods
  extend ActiveSupport::Concern

  included do
    logger.info("Adding HyhullModelMethods to the Hydra model")

    before_save :apply_dublin_core_metadata, :apply_resource_object_label, :apply_additional_descMetadata

    # Store Hyhull workflow properties
    has_metadata name: "properties", label: "Workflow properties", type: Hyhull::Datastream::WorkflowProperties 
    delegate_to :properties, [:depositor, :depositor_email], unique: true  
  
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

  # Apply additional metadata to the descMetadata
  def apply_additional_descMetadata
    if self.respond_to? "descMetadata"
      if self.respond_to? "identifier" then self.identifier = self.pid end
      if self.respond_to? "primary_display_url" then self.primary_display_url = "http://hydra.hull.ac.uk/resources/#{self.pid}" end
      if self.respond_to? "record_change_date" then self.record_change_date = Time.now.strftime("%Y-%m-%d") end
    end
  end

  # Apply a label to the resource object in the Form of 'Title - Authors'
  def apply_resource_object_label
    label = ""
    label_names = ""

    # Set the resource label based upon descMetadata (if it exists...)
    if self.respond_to? "descMetadata"
      begin
        names = self.get_values_from_datastream("descMetadata", [:name, :namePart], {})
        roles = self.get_values_from_datastream("descMetadata", [:name, :role, :text], {})

        # zip name into role array
        role_name = roles.zip(names)

        role_name.each do |person|
          role = person[0].to_s.downcase
          if role == "creator" || role == "author"
            label_names = label_names + person[1] + '; '   
          end
        end
      rescue OM::XML::Terminology::BadPointerError => e
        # Assume that its a resource without author (Set or alike)
        label_names = ""  
      end

      if self.respond_to? "title" 
        title = self.title
      end

      # Truncate the title if its too long (over 100 chars)
      title = title.length > 100 ? title[0..100] << '...': title unless title.nil?
      label = "#{title} - #{label_names}"
      # 255 character limit for labels, we'll limit to 200 to be on the safe side... 
      label = label.length > 200 ? label[0..197] << '...' : label
      #When the label has any leading/trailing spaces strip them off...
      label = label.strip!.nil? ? label : label.strip
    end

    # Set resource label
    self.label = label    
  end
   
  # Override the Hydra::ModelMethods variant to include depositor_email too
  # Adds metadata about the depositor to the asset
  # Most important behavior: if the asset has a rightsMetadata datastream, this method will add +depositor_id+ to its individual edit permissions.
  # @param [String, #user_key] depositor
  #
  def apply_depositor_metadata(depositor, depositor_email)
    prop_ds = self.datastreams["properties"]
    rights_ds = self.datastreams["rightsMetadata"]

    depositor_id = depositor.respond_to?(:user_key) ? depositor.user_key : depositor
  
    if prop_ds
      prop_ds.depositor = depositor_id unless prop_ds.nil?
      prop_ds.depositor_email = depositor_email unless prop_ds.nil?
    end

    rights_ds.permissions({:person=>depositor_id}, 'edit') unless rights_ds.nil?

    return true
  end

  # Applies the rightsMetadata to resource from the defaultObjectRights DS of an APO
  # Where the resource is a generic parent, the rights will be copied to child resources
  def apply_rights_metadata_from_apo
    # if self includes @apply_permissions then it must be true - Objects that implement Hyhull:ResourceWorkflowBehaviour 
    # if self doesn't include @apply_permissions then let the call through - Objects that don't implement Hyhull:ResourceWorkflowBehaviour 
    if (self.respond_to?(:apply_permissions)  && @apply_permissions) || !(self.respond_to?(:apply_permissions) )
      raise "Resource apo is not specified, cannot update rights" unless self.apo
      logger.info("Hyhull::ModelMethods applying rightsMetadata to #{self.id} from APO #{self.apo.id}")
      rights = Hydra::Datastream::RightsMetadata.new(self.inner_object, 'rightsMetadata', {:dsLabel => "Rights metadata"})
      # Get the default_objects_rights content from the the APO
      default_object_rights = self.apo.datastreams["defaultObjectRights"].content

      rights.ng_xml = default_object_rights
      defaultRights = Hyhull::Datastream::DefaultObjectRights.new(self.inner_object, 'defaultObjectRights',  {:dsLabel => "Default object rights metadata"})
      defaultRights.ng_xml = rights.ng_xml.dup
      datastreams["rightsMetadata"] = rights 
      datastreams["defaultObjectRights"] = defaultRights if datastreams.has_key? "defaultObjectRights"

      # If self subscibes to GenericParentBehavaiour it may have child FileAssets
      # When it does have child file assets, the child rightsMetadata needs updating...
      if self.class.ancestors.include?(Hyhull::GenericParentBehaviour) && self.respond_to?(:file_assets)
        self.file_assets.each do |file_asset|
          rights = Hydra::Datastream::RightsMetadata.new(file_asset.inner_object, 'rightsMetadata', {:dsLabel => "Rights metadata"})
          rights.ng_xml = default_object_rights

          file_asset.datastreams["rightsMetadata"] = rights
          file_asset.save
        end
      end
   
      # Reset apply_permissions to false...
      @apply_permissions = false if self.respond_to? :apply_permissions

      return true
    end
  end

  def update_resource_permissions(permission_params, ds_id)    
    xml_content = self.datastreams[ds_id].content    
    ds = Hydra::Datastream::RightsMetadata.new(self.inner_object, ds_id)
    Hydra::Datastream::RightsMetadata.from_xml(xml_content, ds)
    self.datastreams[ds_id] = ds

    # If self subscibes to GenericParentBehavaiour it may have child FileAssets
    # When it does have child file assets, the child rightsMetadata needs updating...
    if self.class.ancestors.include?(Hyhull::GenericParentBehaviour) && self.respond_to?(:file_assets)
      self.file_assets.each do |file_asset|
        fa_xml_content = file_asset.datastreams[ds_id].content    
        fa_ds = Hydra::Datastream::RightsMetadata.new(file_asset.inner_object, ds_id)
        Hydra::Datastream::RightsMetadata.from_xml(fa_xml_content, fa_ds)
        file_asset.datastreams[ds_id] = fa_ds
        # update the datastream's values
        result = fa_ds.update_permissions(permission_params)
        file_asset.save
      end
    end

    # update the datastream's values
    result = ds.update_permissions(permission_params)
  end

  # return the is_governed_by rel
  def is_governed_by
    self.relationships(:is_governed_by)
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