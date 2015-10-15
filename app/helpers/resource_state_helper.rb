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



  # Blacklight/Solr document helpers
  #

  # Returns a html class for the document div, based on whether its appropiate
  # Used for display a resource state wrapper on search results
  def document_resource_state_class document
    resource_state_class = ""
    display_header = display_document_wrapper? document 
    if display_header 
      resource_state_class = "workflow-wrapper-sm workflow-#{resource_state_from_solr_doc(document)}"
    end
    return resource_state_class
  end 


  # For workflow status text inject status into workflow-wrapper-header div
  # eg. <div class="wrapper-header-sm">Workflow Status > Hidden</div> -->
  def resource_state_wrapper_header document
    display_header = display_document_wrapper? document 
    content_tag(:div, t("hyhull.search.documents.resource_state.#{resource_state_from_solr_doc(document)}"), class: "wrapper-header-sm") if display_header
  end

  # Method to determine whether a document wrapper should be included for the resource state
  # Currently hidden and deleted only
  def display_document_wrapper? document 
    display_wrapper = false
    if hidden_resource_state?(document) || deleted_resource_state?(document) ||
       proto_resource_state?(document)
      display_wrapper = true 
    end
  end

  # State based upon Solr Document - Blacklight views
  # #{state}_resource_state?(document) method for checking the state of solr document based 
  # upon the resource_state solr field.  At present the following states exist:-
  # proto, qa, published, hidden, deleted
  ["proto", "qa", "published", "hidden", "deleted"].each do |state|
    define_method("#{state}_resource_state?") do |doc|
       resource_state_from_solr_doc(doc) == state
    end
  end

  private 

  # Return the resource state from the solr_doc
  # At present this includes - "proto", "qa", "published", "hidden", "deleted"
  def resource_state_from_solr_doc document 
    solr_field_value(document, resource_state_fname)
  end

  # Solr field name used for the resource_state
  def resource_state_fname
    "_resource_state_ssi"
  end 

end