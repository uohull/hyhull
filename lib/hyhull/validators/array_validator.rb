class ArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, values)
      [values].flatten.each do |value|
        options.each do |key, args|
          # Added unless key:if as the following was causing problems in validation for state_machine event based validations..
          #{:if=>#<Proc:0x00000005f60630@/home/rubydev/.rvm/gems/ruby-1.9.3-p392@hyhull/gems/state_machine-1.2.0/lib/state_machine/state_context.rb:119 (lambda)>, :length=>{:minimum=>5}}
          unless key == :if
            validator_options = { attributes: attribute }
            validator_options.merge!(args) if args.is_a?(Hash)

            validator_class_name = "#{key.to_s.camelize}Validator"
            validator_class = begin
            validator_class_name.constantize
            
            rescue NameError
              "ActiveModel::Validations::#{validator_class_name}".constantize
            end

            validator = validator_class.new(validator_options)
            validator.validate_each(record, attribute, value)
          end

        end
      end
    end
end