module ResourceStateHelper

  #########################################################
  #                                                       #
  # ResourceStateHelper                                   #
  # * Provides Resource state/workflow helper methods     #
  #                                                       #
  #########################################################


  # Utilised in Edit forms to enable the states to control
  # the colour of frames within the html 
  # Requires a resource object to be passed that will respond to 'resource_state'
  def resource_workflow_class resource
    resource_workflow_class = ""
    if resource.respond_to? :resource_state
      resource_workflow_class  = "workflow-#{resource.resource_state}"
    end
    return resource_workflow_class
  end

  # State based upon Solr Document - Blacklight views
  # #{state}_resource_state?(document) method for checking the state of solr document based 
  # upon the resource_state solr field.  At present the following states exist:-
  # proto, qa, published, hidden, deleted
  ["proto", "qa", "published", "hidden", "deleted"].each do |state|
    define_method("#{state}_resource_state?") do |doc|
       solr_field_value(doc, resource_state_fname) == state
    end
  end

  private 

  # Solr field name used for the resource_state
  def resource_state_fname
    "_resource_state_ssi"
  end 

end