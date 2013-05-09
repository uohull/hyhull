class FilesController < ApplicationController
  
  def create
    if params.has_key?(:Filedata)
      success, message = process_files
    else
      success = false
      message = "You must specify a file to upload" 
    end

    respond_to do |format|
      if success
        format.html { redirect_to(edit_content_metadatum_path(id: params[:container_id]), notice: message) }
      else
        format.html { redirect_to(edit_content_metadatum_path(id: params[:container_id]), flash: { error: message }) }
      end
    end

  end

  def destroy
    container_id = params[:container_id]
    index = params[:index]

    container = ActiveFedora::Base.find(container_id, cast: true)
    success, deleted_asset_id, message = container.delete_by_content_metadata_resource_at(index.to_i)    

    respond_to do |format|
      if success
        format.html { redirect_to(edit_content_metadatum_path(id: container_id), notice: message )}
      else
        format.html { redirect_to(edit_content_metadatum_path(id: container_id), flash: { error: message }) }
      end
    end
   
  end

  def process_files
    container_id = params[:container_id]
    container = ActiveFedora::Base.find(container_id, cast: true)
    success, file_assets, message = container.add_file_content(params[:Filedata])
    return success, message
  end
end