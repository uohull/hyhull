module Hyhull
  module Utils
    class Language
      # ISO 639.2 Language 

      def self.load_config
        File.open(File.join(Rails.root, 'config/languages.yml'), 'r') do |f|
          return YAML.load(f)
        end
      end

      def self.config
        @config ||= load_config
      end

      attr_accessor :code, :name
      
      def initialize(params = {})
        self.code = params[:code] if params[:code]
        self.name = params[:name] if params[:name]
      end

      def self.find_by_code(code)
        name = config[code]
        raise "unable to find language for \"#{language_code}\".  Is it in the config/languages.yml file?" unless name
        row_to_obj(code, name)
      end

      def self.find_by_name(name)
        code = config.key name
        raise "unable to find language code for \"#{name}\".  Is it in the config/languages.yml file?" unless code
        row_to_obj(code, name)

      end 

      def self.all
        config.map { |key, value| row_to_obj(key, value) }
      end

      def self.row_to_obj(code, name)
          Language.new(:code=>code, :name=> name)
      end

    end
  end
end