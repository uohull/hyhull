require 'hyhull'

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
