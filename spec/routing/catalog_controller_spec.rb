# spec/routing/catalog_controller_spec.rb
require 'spec_helper'

describe "CatalogController" do

  describe "#show" do
    it "should route from /resources" do
      get("/resources/test:123").should route_to(action: "show", controller: "catalog", id: "test:123")
    end
  end

  describe "#facet" do
    it "should route from /resources/facet/some_facet" do
      get("/resources/facet/some_facet").should route_to(action: "facet", controller: "catalog", id: "some_facet" )
    end
  end

  describe "#index" do
    it "should route from /resources" do
      get("/resources").should route_to(action: "index", controller: "catalog") 
    end  
  end

  describe "#opensearch" do
    it "should route from /resources/opensearch" do
      get("/resources/opensearch").should route_to(action: "opensearch", controller: "catalog")
    end
  end

end
