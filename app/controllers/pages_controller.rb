class PagesController < ApplicationController
  include BlacklightGoogleAnalytics::ControllerExtraHead
  
  def home
  end

  def about
  end

  def contact
  end

  def cookies
  end

  def takedown
  end

  def rails_status
    @rails_healthy = true
    #@solr_healthy = true
    #@fedora_healthy = true

    # # Check Solr health
    # begin
    #   # Query Solr for a count... 
    #   ActiveFedora::SolrService.count("active_fedora_model_ssi:UketdObject")
    # rescue     
    #    @solr_healthy = false
    # end
 
    # # Check Fedora health
    # begin 
    #   # Load up a standard fedora object
    #   ActiveFedora::Base.find("fedora-system:FedoraObject-3.0", cast: false)
    # rescue     
    #    @fedora_healthy = false
    # end

    if @rails_healthy
      render layout: false
    else
      render layout: false, status: 500
    end
   
  end

end
