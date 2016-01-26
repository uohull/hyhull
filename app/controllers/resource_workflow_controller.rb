class ResourceWorkflowController < ApplicationController
  # We manually add the load_and_authorize_resource CanCan method to do and specify it to use the authorisation based on the Object
  load_and_authorize_resource class: ActiveFedora::Base

  def update
    id = params[:id]
    object = ActiveFedora::Base.find(id, cast: true)
    state = params[:resource_state]

    #Checks to see if this object defines resource_state
    if defined? object.resource_state
      begin
        object.fire_resource_state_event(state)
        if object.save

          # After the object has saved the permissions have potentially changed, therefore we clear the obj permissions cache 
          current_ability.cache.clear

          # Can the user still edit resource post queue transition... 
          user_can_still_edit_resource = can?(:edit, object)

          # If the user is and admin member save message and include pid and
          # workflow queue. Otherwise show generic message.

          notice = { :notice => "Sucessfully added resource #{object.id} to the #{ object.human_resource_state_name } queue" }
          # if current_user.admin?
          #   notice = { :notice => "Sucessfully added resource #{object.id} to the #{ object.human_resource_state_name } queue" }
          # else
          #   notice = { :notice => "Sucessfully sent resource for processing" }
          # end

          if user_can_still_edit_resource
            redirect_to :back, notice 
          else
            redirect_to root_url, notice 
          end

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