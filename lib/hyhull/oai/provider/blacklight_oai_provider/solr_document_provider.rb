module Hyhull::OAI::Provider::BlacklightOaiProvider
  class SolrDocumentProvider < ::OAI::Provider::Base
    attr_accessor :options

    def initialize controller, options = {}

      options[:provider] ||= {}
      options[:document] ||= {}
      options[:sets] ||= {}

      opts = options[:document].merge(sets: options[:sets])

      self.class.model = Hyhull::OAI::Provider::BlacklightOaiProvider::SolrDocumentWrapper.new(controller, opts)

      # Add the local version of the sample identifier
      if options[:provider][:sample_identifier] 
        self.class.identifier = options[:provider][:sample_identifier] 
        options[:provider].delete(:sample_identifier)
      end

      options[:repository_name] ||= controller.view_context.send(:application_name)
      options[:repository_url] ||= controller.view_context.send(:oai_provider_url)
      options[:provider].each do |k,v|
        self.class.send k, v
      end
    end

  end
end
