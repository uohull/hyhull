require 'hyhull'

# Content Location URL Base - Utilised in Content/descMetadata 
# This is used for the basis of the <location type="url">http://hydra.hull.ac.uk... We are purposefully NOT automatically setting this 
# based upon the web server url. We want manual control of this.
CONTENT_LOCATION_URL_BASE = "http://hydra.hull.ac.uk"

# Harvesting OAI Setting
# OAI identifier base
OAI_ITEM_IDENTIFIER_NS = "oai:hull.ac.uk:"

# For all content - Fedora supports the following checksums:-
# "MD5" "SHA-1" "SHA-256" "SHA-384" "SHA-512" or "DISABLED" (for none)
DEFAULT_CHECKSUM_TYPE = "MD5"

# DOI Resolver link
DOI_RESOLVER_SERVICE_URL = "http://dx.doi.org/"

# These are the Hyhull User groups
# String representation used for seeding Database roles and checking permissions - See app/models/ability.rb
# Note: Once implemented it is not recommended to change the string values below 
HYHULL_USER_GROUPS = {
  :content_creator => "contentCreator",
  :content_access_team => "contentAccessTeam",
  :administrator => "admin"
}

HYHULL_QUEUES = {
  "hull:protoQueue" => :proto,
  "hull:QAQueue" => :qa,
  "hull:hiddenQueue" => :hidden,
  "hull:deletedQueue" => :deleted
}

PERMISSION_LEVELS = {
  "Choose Access"=>"none",
  "None"=>"none",
  "View/Download" => "read"
  # Not allowing to assign edit permissions...
  #"Edit" => "edit"
}

PERMISSION_GROUPS = {
  "Choose Group"=>"",
  "committeeSection" => "committeeSection"
}

OWNER_PERMISSION_LEVELS = {
  "Edit" => "edit"
}

# Google Maps API key
GOOGLE_MAPS_KEY = ""

# Hyhull default Institution name
# This is used for auto-population of metadata fields
DEFAULT_INSTITUTION_NAME = "The University of Hull"
