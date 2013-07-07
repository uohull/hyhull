# encoding: utf-8
# spec/datastreams/mods_exam_paper_datastream_spec.rb
require 'spec_helper'

describe Datastream::ModsExamPaper do
  before(:each) do
    @mods = fixture("hyhull/datastreams/exampaper_descMetadata.xml")
    @ds = Datastream::ModsExamPaper.from_xml(@mods)
  end

  it "should expose exam paper metadata for exam paper objects with explicit terms and simple proxies" do
    @ds.title.should == ["44207 Principles of exercise and training (April 2009)"]
    @ds.subject_topic.should == ["Principles of exercise and training"]
    @ds.rights.should == ["© 2009 The University of Hull. All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holder."]
    @ds.identifier.should == ["hull:1765", "hull-private:113"]
    @ds.date_issued.should == ["2009-04"]
    @ds.publisher.should == ["The University of Hull"]
    @ds.extent.should == ["Filesize: 50KB"]
    @ds.mime_type.should == ["application/pdf"]
    @ds.digital_origin.should == ["born digital"]
    @ds.primary_display_url.should ==["http://hydra.hull.ac.uk/resources/hull:1765"]
    @ds.raw_object_url.should == ["http://hydra.hull.ac.uk/assets/hull:1765/genericContent/content"]
    @ds.record_creation_date.should == ["2009-08-07"]
    @ds.record_change_date.should == ["2009-08-08"]
    @ds.language_text.should == ["English"]

    @ds.module_name.should == ["Principles of exercise and training", "Training and Exercise"]
    @ds.module_code.should == ["44207", "44207a"]
    @ds.module_display.should == ["44207 Principles of exercise and training", "44207a Training and Exercise"]
    @ds.department_name.should ==["Business School"]
    @ds.exam_level.should == ["Level 5"]
    @ds.additional_notes.should ==   ["Notes here..."]
  end
  
  it "should expose nested/hierarchical metadata" do
    @ds.language.lang_text.should == ["English"]
    @ds.language.lang_code.should == ["eng"]
    @ds.origin_info.date_issued.should == ["2009-04"] 
    @ds.origin_info.publisher.should == ["The University of Hull"]
    @ds.physical_description.extent.should == ["Filesize: 50KB"]
    @ds.physical_description.mime_type.should == ["application/pdf"]
    @ds.physical_description.digital_origin.should == ["born digital"]
    @ds.location_element.primary_display.should == ["http://hydra.hull.ac.uk/resources/hull:1765"]
    @ds.location_element.raw_object.should == ["http://hydra.hull.ac.uk/assets/hull:1765/genericContent/content"]
    @ds.record_info.record_creation_date.should == ["2009-08-07"]
    @ds.record_info.record_change_date.should == ["2009-08-08"]
    @ds.module.name.should == ["Principles of exercise and training", "Training and Exercise"]
    @ds.module.code.should == ["44207", "44207a"]
    @ds.module.combined_display.should == ["44207 Principles of exercise and training", "44207a Training and Exercise"]
    @ds.organisation.namePart.should == ["Business School"]
  end

  describe "Set metadata methods" do

    it "should let me update subject_topic with multiple items" do
      new_subject_topics = ["New topic", "New topic 2"]
      @ds.add_subject_topic(new_subject_topics)

      @ds.subject_topic.should == new_subject_topics
    end

  end

end