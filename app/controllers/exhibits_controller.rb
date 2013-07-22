# app/controllers/exhibits_controller.rb
class ExhibitsController < ApplicationController
  include Hyhull::Controller::ControllerBehaviour 

  def index
    @exhibits = DisplaySet.find(params[:display_set_id]).children
    respond_to do |format|
      format.html
      format.json { render json: @exhibits}
    end
  end

end
