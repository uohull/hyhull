# FilesController
class FilesController < ApplicationController
  # We manually add the authorize the calling of actions using the authorize_action method below...

  def create 
    if params.has_key?(:Filedata)
      #don't trust the mime type passed form browser during upload. Instead, determine it on file extension
      fileExtension = params[:Filedata][0].original_filename.to_s.split(".").last
      if Mime[fileExtension] != nil
        params[:Filedata][0].content_type = Mime[fileExtension].to_s
      end  
      success, message = process_files
    else
      success = false
      message = "You must specify a file to upload" 
    end
 
    respond_to do |format|
      if success
        notice = { notice: message }    
        format.html { redirect_to :back, notice  }
      else
        notice = { :error => message }    
        format.html { redirect_to :back, notice }
      end
    end

  end

  def destroy
    container_id = params[:container_id]
    index = params[:index]

    container = ActiveFedora::Base.find(container_id, cast: true)
    
    # Manually call authorize_action
    authorize_action(container)

    success, deleted_asset_id, message = container.delete_by_content_metadata_resource_at(index.to_i)    

    respond_to do |format|
      if success
        notice = { notice: message }
        format.html { redirect_to :back, notice }
      else
        notice = { error: message }
        format.html { redirect_to :back, notice }
      end
    end   
  end

  private

  def process_files
    container_id = params[:container_id]
    container = ActiveFedora::Base.find(container_id, cast: true)
    
    # Manually call authorize_action
    authorize_action(container)

    success, file_assets, message = container.add_file_content(params[:Filedata])
    return success, message
  end

  # Authorize action will authorize the action based upon the containers object rights for an update (edit)
  def authorize_action(container_object) 
    authorize! :update, container_object
  end

end