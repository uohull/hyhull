require 'hyhull'

HYHULL_QUEUES = {
  "info:fedora/hull:protoQueue" => :proto,
  "info:fedora/hull:QAQueue" => :qa,
  "info:fedora/hull:hiddenQueue" => :hidden,
  "info:fedora/hull:deletedQueue" => :deleted
}