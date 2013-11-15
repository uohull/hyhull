require 'spec_helper'

class TestModel < ActiveFedora::Base
  include Hyhull::FullTextDatastreamBehaviour
end

describe Hyhull::FullTextDatastreamBehaviour do
  before(:each) do
    @model = TestModel.new
  end

  describe "datastreams" do
    it "should include the fullText datastream definition" do
      @model.fullText.should_not be_nil
    end
  end
  
end