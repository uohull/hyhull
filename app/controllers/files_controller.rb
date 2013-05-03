class FilesController < ApplicationController
  
  def create
    if params.has_key?(:Filedata)
      notice = process_files
      flash[:notice] = notice.join("<br/>".html_safe) unless notice.blank?
    else
      flash[:notice] = "You must specify a file to upload" 
    end

    respond_to do |format|     
        format.html { redirect_to({controller: "content_metadata", action: "edit", id: params[:container_id] }, notice: flash[:notice]) }
    end
  end

  def process_files
    container_id = params[:container_id]
    container = ActiveFedora::Base.find(container_id, cast: true)
    file_assets = container.add_file_content(params[:Filedata])
  end
end