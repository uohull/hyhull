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

    # Overridden for to enable the download of E datastream (hyhull usage includes disseminator metadata)
    # Handle the HTTP show request
    def send_content(asset)
      response.headers['Accept-Ranges'] = 'bytes'

      if request.head?
        content_head
      elsif request.headers['HTTP_RANGE']
        send_range
      else
        send_file_headers! content_options
        
        # For controlGroup E (External) we just return the content 
        if datastream.controlGroup == "E"
          self.response_body = datastream.content
        else
          self.response_body = datastream.stream
        end
      end
    end
end