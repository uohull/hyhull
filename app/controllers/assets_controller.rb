class AssetsController < ApplicationController
  include Hydra::Controller::DownloadBehavior

  def map_view
    if map_view_mimetype.include? datastream.mimeType
      @asset_url = "#{asset_url}/#{datastream.dsid}"
      render layout: false 
    else
      notice = { :alert => "Incompatable Asset: Cannot render through mapview" }
      redirect_to root_url, notice
    end
  end

  protected
    # Overriden the DownloadsBehavior 
    # LoadFromSolr due to issue with GenericContentObjects and ResourceState
    def load_asset
      @asset = ActiveFedora::Base.find(params[:id], cast: true)
    end

    def map_view_mimetype 
      ["application/vnd.google-earth.kmz", "application/vnd.google-earth.kml+xml"]
    end
end