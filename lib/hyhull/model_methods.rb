module Hyhull::ModelMethods
	extend ActiveSupport::Concern

	included do
		logger.info("Adding HyhullModelMethods to the Hydra model")
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

end