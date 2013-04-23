require 'spec_helper'

class GenericParentBehaviourTest < ActiveFedora::Base
  include Hyhull::GenericParentBehaviour

  def owner_id
    "fooAdmin"
  end

  def initialize
    super
  end

end

describe Hyhull::ModelMethods do

  before(:each) do
    @testclassone = GenericParentBehaviourTest.new
  end

  describe "datastream_behaviour" do
    it "should define file_assets methods for setting and retrieving File asset objects" do
      @testclassone.should respond_to :file_assets
      @testclassone.file_assets.should == []
    end
  end

end
