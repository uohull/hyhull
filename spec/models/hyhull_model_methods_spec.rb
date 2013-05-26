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

class ModelMethodsTestClassThree < ActiveFedora::Base
  include Hyhull::ModelMethods

  #Add some attributes to the class to enable some metadata testing
  attr_accessor :title, :date_valid, :genre

  has_metadata name: "descMetadata", label: "MODS metadata", type: Datastream::ModsEtd

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

  context "additional metadata" do
    describe "apply_depositor_metadata" do
      it "should store the depositor e-mail address along with their user_id" do
        @testclassone.apply_depositor_metadata("usera", "usera@example.com")
        @testclassone.save
        @testclassone.properties.depositor.should == ["usera"]
        @testclassone.properties.depositor_email.should == ["usera@example.com"]
      end
    end

    describe "#apply_resource_object_label" do
      before do
        @testclassthree = ModelMethodsTestClassThree.new
      end
      it "should return an object label based upon the descMetadata title and, names and roles" do
        @testclassthree.title = "This is a test document"
        @testclassthree.descMetadata.person_name = ["Smith, John"]
        @testclassthree.descMetadata.person_role_text = ["Creator"]
        @testclassthree.apply_resource_object_label
        @testclassthree.label.should == "This is a test document - Smith, John;"
      end  
      it "should return an object label that is limited to 200 characters" do
        @testclassthree.title = "This is the dataset of all datasets, actually this is a rather large dataset with a title that is likely to be too long for a fedora-label"
        @testclassthree.descMetadata.add_names(["Lamb, Simon.", "Green, Richard.", "Smith, John.", "Garbutt, Richard.", "Jones, Peter.", "Bradfield, James.", "Jones, Nick."], ["Author", "Author", "Author", "Author", "Author", "Author", "Author"], "person")
        @testclassthree.apply_resource_object_label
        @testclassthree.label.should == "This is the dataset of all datasets, actually this is a rather large dataset with a title that is lik... - Lamb, Simon.; Green, Richard.; Smith, John.; Garbutt, Richard.; Jones, Peter.; Bradfield, J..."
      end
    end

  end
end

