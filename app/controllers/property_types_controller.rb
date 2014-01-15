class PropertyTypesController < ApplicationController
  include Hyhull::Controller::ControllerBehaviour 
  
  def index
    @property_types = PropertyType.all
  end
end