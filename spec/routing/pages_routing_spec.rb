# spec/controllers/pages_controller_spec.rb
require 'spec_helper'

describe "routes to the pages controller" do
    it "routes to #home" do
      get("/home").should route_to("pages#home")
    end

    it "routes to #about" do
      get("/about").should route_to("pages#about")
    end

    it "routes to #contact" do
      get("/contact").should route_to("pages#contact")
    end

    it "routes to #cookies" do
      get("/cookies").should route_to("pages#cookies")
    end

    it "routes to #takedown" do
      get("/takedown").should route_to("pages#takedown")
    end
end
  