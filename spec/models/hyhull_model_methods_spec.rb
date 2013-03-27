require 'spec_helper'

class TestClassOne < ActiveFedora::Base
	include Hyhull::ModelMethods

	def owner_id
		"fooAdmin"
	end

	def initialize
		super
	end

end


describe Hyhull::ModelMethods do

	before(:each) do
		@testclassone = TestClassOne.new
	end

	describe "cmodel" do
    it "should properly return the appropriate cModel declaration" do
      @testclassone.cmodel.should == "info:fedora/hull-cModel:testClassOne"
    end
  end

end