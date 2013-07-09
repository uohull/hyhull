class AssetsController < ApplicationController
  include Hydra::Controller::DownloadBehavior

  protected
    # Overriden the DownloadsBehavior 
    # LoadFromSolr due to issue with GenericContentObjects and ResourceState
    def load_asset
      @asset = ActiveFedora::Base.find(params[:id], cast: true)
    end
end