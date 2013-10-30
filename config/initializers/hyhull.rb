require 'hyhull'

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

DEPARTMENTS = {
  "ICTD" => "ICTD",
  "LLI" => "LLI",
  "Computer Science" => "Computer Science"
}
