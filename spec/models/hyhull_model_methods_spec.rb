require 'spec_helper'

class ModelMethodsTestClassOne < ActiveFedora::Base
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
		@testclassone = ModelMethodsTestClassOne.new
	end

	describe "cmodel" do
    it "should properly return the appropriate cModel declaration" do
      @testclassone.cmodel.should == "info:fedora/hull-cModel:modelMethodsTestClassOne"
    end
  end

end