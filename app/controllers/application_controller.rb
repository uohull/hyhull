class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller 
   include Blacklight::Controller  
# Adds Hydra behaviors into the application controller 
  include Hydra::Controller::ControllerBehavior

  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 

  layout 'blacklight'

  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  # Method to determine whether a login is required before continuing to action....
  # Specifying ?login=true onto a URL will force the controller to undertake a redirect to login page, and back again after a successful login.  
  def require_login
    unless params["login"].nil?
      #Call the devise helper to authenticate the user (returns back to orig dest)
      authenticate_user! if params["login"] == "true"
    end
  end

end
