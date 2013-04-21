class ContentMetadataController < ApplicationController
  include Hyhull::Controller::ControllerBehaviour 

  def edit
    object = ActiveFedora::Base.find(params[:id], cast: true)

    if object.datastreams.include?("contentMetadata")
      @content_metadata = object.contentMetadata
    end

    @content_metadata

  end

  def update
    object = ActiveFedora::Base.find(params[:id], cast: true)

    if object.datastreams.include?("contentMetadata")
      object.update_attributes(params[:content_metadata])  
    end

    respond_to do |format|
      if object.save
        format.html { redirect_to({ action: "edit", id: params[:id] }, notice: 'ContentMetadata was successfully updated.' ) }
        format.json { render json: params[:id], status: :created, location: params[:id] }
      else
        format.html { redirect_to({ action: "edit", id: params[:id] }, :alert => @content_metadata.errors.messages.values.to_s) }
      end
    end

  end
  
end