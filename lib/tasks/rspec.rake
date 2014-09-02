require 'bundler/setup'

RSpec::Core::RakeTask.new(:spec) if defined? RSpec
#Makre sure hyhull default task is used...
#task :default => :spec