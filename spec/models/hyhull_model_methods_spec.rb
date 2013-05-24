require 'spec_helper'

class ModelMethodsTestClassOne < ActiveFedora::Base
	include Hyhull::ModelMethods

  #Add some attributes to the class to enable some metadata testing
  attr_accessor :title, :date_issued, :date_valid, :genre

	def owner_id
		"fooAdmin"
	end

	def initialize
		super
	end

end

class ModelMethodsTestClassTwo < ActiveFedora::Base
  include Hyhull::ModelMethods

  #Add some attributes to the class to enable some metadata testing
  attr_accessor :title, :date_valid, :genre

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

  context "added datastreams" do
    before(:each) do
      @testclassone.title = "A new test resource"
      @testclassone.date_issued = "2012-01-01"
      @testclassone.date_valid = ""
      @testclassone.genre = "Test asset"
    end
    describe "dc" do
      it "should define the required delegates" do
        @testclassone.respond_to?("dc_title").should be_true
        @testclassone.respond_to?("dc_genre").should be_true
        @testclassone.respond_to?("dc_date").should be_true     
      end
      it "should define the required delegates as unique" do
        @testclassone.dc_title.should == ""
        @testclassone.dc_genre.should == ""
        @testclassone.dc_date.should == ""
      end
      it "should copy title, genre and a date from the base object on save" do
        @testclassone.save
        @testclassone.dc_title.should == "A new test resource"
        #date_issued takes precidence over date_valid
        @testclassone.dc_date.should == "2012-01-01"
        @testclassone.dc_genre.should == "Test asset"
      end
      it "should take a copy of date_valid if date_issued does not exist" do
        testclasstwo = ModelMethodsTestClassTwo.new
        testclasstwo.date_valid = "2020"
        testclasstwo.save
        testclasstwo.dc_date.should == "2020"
      end

    end

  end

end

