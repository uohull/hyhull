# spec/controllers/assets_controller_spec.rb
require 'spec_helper'

describe AssetsController do
  describe "map_view" do
    # Use test dataset asset hull:2155 
    it "should render with a compatable asset" do
      get :map_view, id: "hull:2155", datastream_id: "content07"
      response.should render_template("map_view")
    end

    it "should not render an Incompatable asset" do
      get :map_view, id: "hull:2155", datastream_id: "content"
      flash[:alert].should == "Incompatable Asset: Cannot render through mapview"
      response.should redirect_to root_url
    end
  end
end