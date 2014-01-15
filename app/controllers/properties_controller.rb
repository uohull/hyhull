class PropertiesController < ApplicationController  
  include Hyhull::Controller::ControllerBehaviour 
  
  def index
    begin
      @property_type = PropertyType.find(params[:property_type_id])
      @properties = @property_type.properties
      @property = Property.new
    rescue Exception => e
      notice = { :alert => "There was an error: #{e}" }
      redirect_to property_types_path, notice
    end
  end

  def edit
    begin
      @property = Property.find(params[:id])
    rescue Exception => e
      notice = { :alert => "There was an error: #{e}" }
      redirect_to property_type_properties_path(params[:property_type_id]), notice
    end
  end

  def update
    begin
      property = Property.find(params[:id])
      property.update_attributes!(params[:property])
      
      if property.save
        notice = { :notice => "Property successfully updated" }
        redirect_to edit_property_type_property_path(id: params[:id]), notice
      end
    rescue Exception => e
      notice = { :alert => "#{e}" }
      redirect_to edit_property_type_property_path(id: params[:id]), notice
    end
  end

  def create
    @property = Property.new(params[:property])
    @property.property_type = PropertyType.find(params[:property_type_id])
    
    if @property.save
      redirect_to property_type_properties_path(params[:property_type_id])
    else
      notice = { :alert => "Could not create property: #{ @property.errors.full_messages.to_sentence }" }
      redirect_to property_type_properties_path(params[:property_type_id]), notice
    end
  end

  def destroy 
    @property = Property.find(params[:id])
    @property.delete
    redirect_to :back
  end

end
