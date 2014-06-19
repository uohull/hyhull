module BlacklightOaiProvider
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
      records = @controller.get_search_results(@controller.params, {:sort => @timestamp_field +' asc',:fq => ["active_fedora_model_ssi:\"HarvestingSet\""] , :fl => "id, oai_set_spec_ssim, oai_set_name_ssim" }).last
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
          # Search solr for the id of the set_spec 
          set_record = @controller.get_search_results(@controller.params, {:fq => ["oai_set_spec_ssim:\"#{set_spec}\" "],  :fl => ["id"] , :sort => @timestamp_field + ' asc', :per_page => @limit}).last.first 
          set_id = set_record.get("id")
          # Retrieve items recording membership of the harvesting set_id
          response, records = @controller.get_search_results(@controller.params, {:fq => ["is_member_of_collection_ssim:\"info:fedora/#{set_id}\" "], :sort => @timestamp_field + ' asc', :per_page => @limit})
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
  end
end

