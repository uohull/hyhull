require 'active_support'

module Hyhull
  extend ActiveSupport::Autoload
  autoload :RoleMapperBehaviour
  autoload :Datastream
  autoload :Models
  autoload :Resque
end

require 'hyhull'

