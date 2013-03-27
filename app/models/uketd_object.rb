# app/models/uketd_object.rb
# Fedora object for the uketd ETD content type
class UketdObject < ActiveFedora::Base
	include Hydra::ModelMethods
	include Hyhull::ModelMethods

	has_metadata :name => "descMetadata", :type => ModsUketd
	has_metadata :name => "rightsMetadata", :type => Hydra::Datastream::RightsMetadata

	#Delegate these attributes to the respective datastream
	#Unique fields
	delegate :title, :to=>"descMetadata", :unique=>"true"
	#delegate :author_name, :to=>"descMetadata", :unique=>"true"
	delegate :abstract, :to=>"descMetadata", :unique=>"true"
	delegate :date_issued, :to=>"descMetadata", :unique=>"true"
	delegate :date_valid, :to=>"descMetadata", :unique=>"true"
	delegate :rights, :to=>"descMetadata", :unique=>"true"
	delegate :ethos_identifier, :to=>"descMetadata", :unique=>"true"
	delegate :language_text, :to=>"descMetadata", :unique=>"true"
	delegate :language_code, :to=>"descMetadata", :unique=>"true"
	delegate :publisher, :to=>"descMetadata", :unique=>"true"
	delegate :qualification_level, :to=>"descMetadata", :unique=>"true"
	delegate :qualification_name, :to=>"descMetadata", :unique=>"true"
	delegate :dissertation_category, :to=>"descMetadata", :unique=>"true"
	delegate :type_of_resource, :to=>"descMetadata", :unique=>"true"
	delegate :genre, :to=>"descMetadata", :unique=>"true"
	delegate :mime_type, :to=>"descMetadata", :unique=>"true"
	delegate :digital_origin, :to=>"descMetadata", :unique=>"true"
	delegate :identifier, :to=>"descMetadata", :unique=>"true"
  delegate :primary_display_url, :to=>"descMetadata", :unique=>"true"
  delegate :raw_object_url, :to=>"descMetadata", :unique=>"true"
  delegate :extent, :to=>"descMetadata", :unique=>"true"
  delegate :record_creation_date, :to=>"descMetadata", :unique=>"true"
  delegate :record_change_date, :to=>"descMetadata", :unique=>"true"

 	#Non-unique fields
  delegate :subject_topic, :to=>"descMetadata", :unique=>"false"
  #delegate :supervisor_name, :to=>"descMetadata", :unique=>"false"
  #delegate :sponsor_name, :to=>"descMetadata", :unique=>"false"
  delegate :grant_number, :to=>"descMetadata", :unique=>"false"

end

