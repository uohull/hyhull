# spec/routing/assets_controller_spec.rb
require 'spec_helper'

describe "routes to the assets controller" do
    it "routes to assest#show" do
      get("/assets/hull:756a/content").should route_to(action: "show", controller: "assets", id: "hull:756a", datastream_id: "content")
    end
end
  