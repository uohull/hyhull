module Hyhull::OAI::Provider::BlacklightOaiProvider
  class SolrDocumentWrapper < ::OAI::Provider::Model
    attr_reader :model, :timestamp_field
    attr_accessor :options

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
        response, records = @controller.get_search_results(@controller.params, {:q => [build_query(options)], :sort => @timestamp_field + ' asc', :rows=> @limit })
        
        if @limit && response.total >= @limit
          return select_partial(OAI::Provider::ResumptionToken.new(options.merge({:last => 1})))
        end
      else
        records = @controller.get_search_results(@controller.params, {:q => ["id:\"#{ selector.split('/', 2).last }\""]}).last.first 
      end
      records
    end

    def select_partial token
      records = @controller.get_search_results(@controller.params.merge({ :q => [build_query(token.to_conditions_hash)], :sort => @timestamp_field + ' asc', :page => token.last, :rows=> @limit}), {}).last

      raise ::OAI::ResumptionTokenException.new unless records

      OAI::Provider::PartialResult.new(records, token.next(token.last+1))
    end

    def next_set(token_string)
      raise ::OAI::ResumptionTokenException.new unless @limit

      token = OAI::Provider::ResumptionToken.parse(token_string)
      select_partial(token)
    end

    private

    def build_query(options={})
      query = ""

      if options.has_key? :set          
        config_set, set_key_field, solr_field = configuration_set?(options[:set])

        if config_set
          query =  "#{solr_field}:\"#{set_key_field}\" "
        else
          set_id =  set_id_from_set_spec(options[:set])
          query =  "is_member_of_collection_ssim:\"info:fedora/#{set_id}\" "
        end
      end

      if options.has_key?(:from) && options.has_key?(:until)           
        datetime_query = datetime_solr_query(options[:from], options[:until])
        query.empty? ? query = datetime_query : query.concat(" AND  #{datetime_query}")
      end

      return query
   end

   def datetime_solr_query(from, to)
      "#{self.timestamp_field}:[#{from.utc.iso8601} TO #{to.utc.iso8601}]"
   end
   

    # Method that queries to retrieve the set PID based upon the set_spec identifier
    def set_id_from_set_spec(set_spec)
        set_record = @controller.get_search_results(@controller.params, {:fq => ["oai_set_spec_ssim:\"#{set_spec}\" "],  :fl => ["id"] , :sort => @timestamp_field + ' asc', :per_page => @limit}).last.first 
        set_record.get("id") || ""
    end

    def  build_sets_response(records)
      sets = []      
      records.each do |set|
        unless set.get("oai_set_spec_ssim").to_s.empty?
          sets << OAI::Set.new(spec: set.get("oai_set_spec_ssim"), name: set.get("oai_set_name_ssim"), description: "" )
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
            sets <<OAI::Set.new(spec: set_spec, name: set_name, description: set_description)
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

