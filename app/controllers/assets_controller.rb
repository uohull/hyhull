class AssetsController < ApplicationController
  include Hydra::Controller::DownloadBehavior
  include IrusAnalytics::Controller::AnalyticsBehaviour 

  before_filter :filter_datastreams
  after_filter :send_analytics 

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

    # Return the item_identier - for use with the IrusAnalytics gem
    def item_identifier
      if @asset.is_a? FileAsset
        id = @asset.container.id 
      else
        id = @asset.id
      end
      oai_prefix.nil? ? id : "#{oai_prefix}:#{id}" 
    end

     # oai_prefix is returned from the CatalogController (uses the Blacklight oai configuration)
    def oai_prefix
      CatalogController.configure_blacklight.oai[:provider][:record_prefix] || nil
    end

    # This filter_datastreams that we do not generally like users to download
    def filter_datastreams
      ds_ids = ["DC", "RELS-EXT", "contentMetadata", "rightsMetadata", "properties"]      
      if ds_ids.include? datastream.dsid
        redirect_to root_url
      end
    end

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

    # Override this if you'd like a different filename
    # @return [String] the filename
    def datastream_name
      filename_from_datastream_name_and_mime_type(asset.pid, datastream.dsid, datastream.mimeType)
    end

    def filename_from_datastream_name_and_mime_type(pid, datastream_name, mime_type)
      # if mime type exists, grab the first extension listed for the first returned mime type
      extension = MIME::Types[mime_type].length > 0 ? ".#{MIME::Types[mime_type].first.extensions.first}" : ""
      "#{datastream_name}-#{pid.gsub(/:/,'_')}#{extension}"
    end

end