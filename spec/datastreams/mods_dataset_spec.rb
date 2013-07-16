# encoding: utf-8
# spec/datastreams/mods_dataset_spec.rb
require 'spec_helper'

# ModsDateset uses ModsMetadataBase OM terminology - for more tests see /spec/datastreams/mods_metadata_base_spec.rb
# Datasteam::ModsDataset just specifies an xml_template 
describe Datastream::ModsDataset do

  describe "class methods" do
    it "xml_template should specify the dataset genre" do
      Datastream::ModsDataset.xml_template.to_s.include?("<genre>Dataset</genre>").should be_true
    end

    it "xml_template should specify dataset as default typeOfResource genre" do
      Datastream::ModsDataset.xml_template.to_s.include?("<typeOfResource>dataset</typeOfResource>").should be_true
    end

    it "ModsGenericContent self.person_role_terms should only return the valid roles" do
      Datastream::ModsGenericContent.person_role_terms.sort.should ==  ["Author", "Creator", "Editor", "Module leader", "Photographer", "Sponsor", "Supervisor"]
    end
    it "ModsGenericContent self.organisation_role_terms should only return the valid roles" do
      Datastream::ModsGenericContent.organisation_role_terms.sort.should ==  ["Creator", "Host", "Sponsor"]
    end
  end
  
end