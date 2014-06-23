module BlacklightOaiProvider
  class SolrDocumentWrapper < ::OAI::Provider::Model
    attr_reader :model, :timestamp_field
    attr_accessor :options

    # A new struct for a Set
    Set = Struct.new(:spec, :name, :description) 

    def initialize(controller, options = {})
      @controller = controller

      defaults = { :timestamp => 'timestamp', :limit => 15} 
      @options = defaults.merge options
      @timestamp_field = @options[:timestamp]
      @limit = @options[:limit]
    end

    def sets
      # Retrieve sets from Solr_index are marked as HarvestingSet ActiveFedoraModel
      records = @controller.get_search_results(@controller.params, {:sort => @timestamp_field +' asc',:fq => ["active_fedora_model_ssi:\"HarvestingSet\""] , :fl => "id, oai_set_spec_ssim, oai_set_name_ssim" }).last
      sets = build_sets_response(records)
      # Builds static sets from configuration options based on model 
      sets.concat(build_sets_from_options)
      sets
    end

    def earliest
      Time.parse @controller.get_search_results(@controller.params, {:sort => @timestamp_field +' asc', :rows => 1}).last.first.get(@timestamp_field)
    end

    def latest
      Time.parse @controller.get_search_results(@controller.params, {:sort => @timestamp_field +' desc', :rows => 1}).last.first.get(@timestamp_field)
    end

    def find(selector, options={})
      return next_set(options[:resumption_token]) if options[:resumption_token]
      if :all == selector
        if options.has_key? :set          
          set_spec = options[:set]

          config_set, set_key_field, solr_field = configuration_set?(set_spec)
          # If this is a configuration based set we will query solr based upon the configuration_set_solr_field
          if config_set
            response, records = @controller.get_search_results(@controller.params, {:q => ["#{solr_field}:\"#{set_key_field}\" "], :sort => @timestamp_field + ' asc', :per_page => @limit})
          else
            # Else we query for sets based upon membership of the HarvestingSet collection..
            # Search solr for the id of the set_spec 
            set_record = @controller.get_search_results(@controller.params, {:fq => ["oai_set_spec_ssim:\"#{set_spec}\" "],  :fl => ["id"] , :sort => @timestamp_field + ' asc', :per_page => @limit}).last.first 
            set_id = set_record.get("id")
            # Retrieve items recording membership of the harvesting set_id
            response, records = @controller.get_search_results(@controller.params, {:q => ["is_member_of_collection_ssim:\"info:fedora/#{set_id}\" "], :sort => @timestamp_field + ' asc', :per_page => @limit})
          end

         else
          response, records = @controller.get_search_results(@controller.params, {:sort => @timestamp_field + ' asc', :per_page => @limit})
        end

        if @limit && response.total >= @limit
          return select_partial(OAI::Provider::ResumptionToken.new(options.merge({:last => 0})))
        end
      else
        records = @controller.get_search_results(@controller.params, {:q => ["id:\"#{ selector.split('/', 2).last }\""]}).last.first 
      end
      records
    end

    def select_partial token
      records = @controller.get_search_results(@controller.params, {:sort => @timestamp_field + ' asc', :per_page => @limit, :page => token.last}).last

      raise ::OAI::ResumptionTokenException.new unless records

      OAI::Provider::PartialResult.new(records, token.next(token.last+1))
    end

    def next_set(token_string)
      raise ::OAI::ResumptionTokenException.new unless @limit

      token = OAI::Provider::ResumptionToken.parse(token_string)
      select_partial(token)
    end

    def  build_sets_response(records)
      sets = []      
      records.each do |set|
        unless set.get("oai_set_spec_ssim").to_s.empty?
          sets << Set.new(set.get("oai_set_spec_ssim"), set.get("oai_set_name_ssim"), "")
        end
      end
      sets
    end

    # Builds  virtual sets from the configuration options. 
    def build_sets_from_options
      sets = []
      if @options[:sets]
        @options[:sets].each_pair do |k,v|
          set_spec = v[:set_spec] if v.has_key? :set_spec
          set_name = v[:set_name] if v.has_key? :set_name
          set_description = v[:set_description] if v.has_key? :set_description
          
          unless set_spec.nil? 
            sets << Set.new(set_spec, set_name, set_description)
          end
        end
      end      
      sets                
    end

    # Does the set_spec belongs to the configuration based sets
    # returns true/false, set key field, solr_field for querying against
    def configuration_set?(set_spec)
      if @options[:sets]
        @options[:sets].each_pair do |k,v|
          if v[:set_spec] == set_spec
            return true, k.to_s, v[:solr_field]
          end 
        end
      end
      return false, "", ""
    end  

  end
end

