# Profile controller - this is used for providing a simple read-only view of a users profile - viewable only to themselves 
class ProfileController < ApplicationController
  before_filter :authenticate_user!

  def index
    @user = current_user
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user }
    end
  end
end 