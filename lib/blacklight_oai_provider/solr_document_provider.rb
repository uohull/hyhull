module BlacklightOaiProvider
  class SolrDocumentProvider < ::OAI::Provider::Base
    attr_accessor :options

    def initialize controller, options = {}
      options[:provider] ||= {}
      options[:document] ||= {}

      self.class.model = SolrDocumentWrapper.new(controller, options[:document])
      # Add the UketdDC metadata provider
      self.class.register_format(OAI::Provider::Metadata::UketdDC.instance)
      
      options[:repository_name] ||= controller.view_context.send(:application_name)
      options[:repository_url] ||= controller.view_context.send(:oai_provider_url)

      options[:provider].each do |k,v|
        self.class.send k, v
      end
    end

    # Equivalent to '&verb=ListSets', returns a list of sets that are supported
    # by the repository or an error if sets are not supported.
    def list_sets(options = {})
      BlacklightOaiProvider::ListSets.new(self.class, options).to_xml
    end
  end
end
