class PropertyTypesController < ApplicationController
  def index
    @property_types = PropertyType.all
  end
end