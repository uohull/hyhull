require "spec_helper"

class ValidGenericContentTestClass < ActiveFedora::Base
  has_metadata :name => "descMetadata", :type => ActiveFedora::QualifiedDublinCoreDatastream do |m|
  end
  has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata
end

describe ActiveFedora::ContentModel do
  
  describe "class_name overrides" do
    before(:each) do
      @test_cmodel = ActiveFedora::ContentModel.new
    end
    
    it 'should provide #pid_from_ruby_class' do
      ActiveFedora::ContentModel.should respond_to(:sanitized_class_name)
    end
    
    describe "#pid_from_ruby_class" do
      it "should construct pids" do
       ActiveFedora::ContentModel.sanitized_class_name(@test_cmodel.class).should == "activeFedora_ContentModel"
      end
      it "should construct hull pid namespaces correctly" do
        ActiveFedora::ContentModel.sanitized_class_name(UketdObject).should eql('uketdObject')
        ActiveFedora::ContentModel.sanitized_class_name(ExamPaper).should eql('examPaper')
        ActiveFedora::ContentModel.sanitized_class_name(GenericContent).should eql('genericContent')
        ActiveFedora::ContentModel.sanitized_class_name(StructuralSet).should eql('structuralSet')
        ActiveFedora::ContentModel.sanitized_class_name(JournalArticle).should eql('journalArticle')
      end
    end
    
    describe "#uri_to_ruby_class" do
      it "should correctly return the ruby class of a given uri" do
        ActiveFedora::ContentModel.uri_to_model_class("info:fedora/hull-cModel:uketdObject").should eql(UketdObject)
        ActiveFedora::ContentModel.uri_to_model_class("info:fedora/hull-cModel:examPaper").should eql(ExamPaper)
        ActiveFedora::ContentModel.uri_to_model_class("info:fedora/hull-cModel:genericContent").should eql(GenericContent)
        ActiveFedora::ContentModel.uri_to_model_class("info:fedora/hull-cModel:structuralSet").should eql(StructuralSet)
        ActiveFedora::ContentModel.uri_to_model_class("info:fedora/hull-cModel:journalArticle").should eql(JournalArticle)
      end
    end

  end

  describe "known_models_for" do

    it "should return the appropiate model for the existing object models" do
      # Lets load an ETD into 'ActiveFedora::Base'
      uketd_object = ActiveFedora::Base.find("hull:756", cast: false)
      journal_article = ActiveFedora::Base.find("hull:1729", cast: false)
      # Now lets see if it matches to the correct object type 'UketdObject/JournalArticle'
      ActiveFedora::ContentModel.known_models_for(uketd_object).include?(UketdObject).should be_true
      ActiveFedora::ContentModel.known_models_for(journal_article).include?(JournalArticle).should be_true
    end

    it "should return the GeneriContent model for a valid object without a specific object model" do
      presentation = ActiveFedora::Base.find("hull:2106", cast: false)
      ActiveFedora::ContentModel.known_models_for(presentation).include?(GenericContent).should be_true
    end
  end


  describe "default_model" do
    before(:each) do
      @testObject1 = ValidGenericContentTestClass.create
      @testObject2 = ActiveFedora::Base.create
    end

    after(:each) do
      @testObject1.delete
      @testObject2.delete
    end

    it "should return the default_model as GenericContent for valid objects" do
      # Object contains descMetadata and rightsMetadata
      ActiveFedora::ContentModel.default_model(@testObject1).should == GenericContent
    end
    it "should return the default_model as ActiveFedora::Base for non-valid objects" do
      # Object does not contain descMetadata and rightsMetadata
      ActiveFedora::ContentModel.default_model(@testObject2).should == ActiveFedora::Base
    end 

  end

end