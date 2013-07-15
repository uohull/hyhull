# The following code represents hull-specific overrides to ActiveFedora. 
module ActiveFedora
  class ContentModel < Base  

    ### Serialize class names with first letter downcased
    def self.sanitized_class_name(klass)
      #Do not downcase FileAsset 
      if klass.name != "FileAsset"
        class_name = klass.name.gsub(/(::)/, '_')
        class_name[0,1].downcase + class_name[1..-1]
      else
          klass.name.gsub(/(::)/, '_')
      end      
    end

    ### Override this method if you need something other than the default strategy
    # Returns GenericContent as the default model if descMetadata and rightsMetadata exits
    def self.default_model(obj)
      if obj.datastreams['descMetadata'] && obj.datastreams['rightsMetadata']
        if ActiveFedora::Model.send(:class_exists?, "GenericContent")
          m = Kernel.const_get("GenericContent")
          if m
            return m
          end
        end
      end
      ActiveFedora::Base
    end

  end
end


module ActiveFedora
  class RelationshipGraph

    # Create an RDF statement
    # @param uri a string represending the subject
    # @param predicate a predicate symbol
    # @param target an object to store
    def build_statement(uri, predicate, target)
      raise "Not allowed anymore" if uri == :self
      # Overriding this line:-
      #target = target.internal_uri if target.respond_to? :internal_uri
      target = target.internal_uri if target.class.method_defined? :internal_uri
      subject =  RDF::URI.new(uri)  #TODO cache
      if target.is_a? RDF::Literal or target.is_a? RDF::Resource
        object = target
      else
        begin
          target_uri = (target.is_a? URI) ? target : URI.parse(target)
          if target_uri.scheme.nil?
            raise ArgumentError, "Invalid target \"#{target}\". Must have namespace."
          end
          if target_uri.to_s =~ /\A[\w\-]+:[\w\-]+\Z/
            raise ArgumentError, "Invalid target \"#{target}\". Target should be a complete URI, and not a pid."
          end
        rescue URI::InvalidURIError
          raise ArgumentError, "Invalid target \"#{target}\". Target must be specified as a literal, or be a valid URI."
        end
        object = RDF::URI.new(target)
      end
      predicate = ActiveFedora::Predicates.find_graph_predicate(predicate) unless predicate.kind_of? RDF::URI
      RDF::Statement.new(subject, predicate, object)    
    end

  end
end