class ResourceWorkflowController < ApplicationController

  def update

    id = params[:id]
    object = ActiveFedora::Base.find(id, cast: true)
    state = params[:resource_state]

    #Checks to see if this object defines resource_state
    if defined? object.resource_state
      begin
        object.fire_resource_state_event(state)
        if object.save
          notice = { :notice => "Sucessfully added resource #{object.id} to the #{ object.human_resource_state_name } queue" }
          redirect_to root_url, notice 
        else
          notice = { :alert => "Problems saving the resource to the #{state} queue...</br></br>#{object.errors.full_messages.join("</br>")}".html_safe }
          redirect_to :back, notice 
        end
      rescue Exception => e
        notice = { :alert => "Problems executing the '#{state}' transition on the resource" }
        redirect_to :back, notice 
      end
    end  

  end

end