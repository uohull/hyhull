module Hyhull::OAI::Provider::BlacklightOaiProvider
  class SolrDocumentProvider < ::OAI::Provider::Base
    attr_accessor :options

    def initialize controller, options = {}
      options[:provider] ||= {}
      options[:document] ||= {}
      options[:sets] ||= {}

      opts = options[:document].merge(sets: options[:sets])

      self.class.model = Hyhull::OAI::Provider::BlacklightOaiProvider::SolrDocumentWrapper.new(controller, opts)
      
      options[:repository_name] ||= controller.view_context.send(:application_name)
      options[:repository_url] ||= controller.view_context.send(:oai_provider_url)

      options[:provider].each do |k,v|
        self.class.send k, v
      end
    end

  end
end
