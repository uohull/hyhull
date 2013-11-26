class ContentMetadataController < ApplicationController
  # We manually add the load_and_authorize_resource CanCan method to do and specify it to use the authorisation based on the Object
  load_and_authorize_resource class: ActiveFedora::Base

  before_filter :set_return_url

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
        notice = { :notice => "The content metadata was sucessfully updated" }       
        format.html {  redirect_to :back, notice  }
        format.json { render json: params[:id], status: :created, location: params[:id] }
      else
        notice = { :alert => "There was an issue saving the content metadata. Cause: #{object.errors.messages.values.to_s}" } 
        format.html { redirect_to :back, notice }
      end
    end

  end

  private 

  # Set the return url for going back to the referrer ie. object_type/:id
  def set_return_url
    return_url = request.referer.to_s
    # do not overwrite return url with the content_metadata url..
    unless return_url.include? "content_metadata"
        session[:return_url] = return_url
    end
  end
  
end