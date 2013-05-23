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

  context "utility methods" do
    describe "to_long_date" do
      it "should return the appropiate long date versions of the inputted dates" do
        @testclassone.to_long_date("2001").should == "2001-01-01"
        @testclassone.to_long_date("1983-03").should == "1983-03-01"
        @testclassone.to_long_date("1999-05-10").should == "1999-05-10"
      end
    end
  end

end

