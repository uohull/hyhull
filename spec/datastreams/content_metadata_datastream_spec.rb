# spec/datastreams/content_metadata_datastream_spec.rb
require 'spec_helper'

describe Hyhull::Datastream::ContentMetadata do

  context "when loading from xml" do 
    before(:each) do
      @mods = fixture("hyhull/datastreams/contentMetadata.xml")
      @ds = Hyhull::Datastream::ContentMetadata.from_xml(@mods)
    end

    it "should expose content metadata using explicit terms and simple proxies" do
      #Explicit terms
      @ds.resource.resource_id.should == ["Document"]
      @ds.resource.sequence.should == ["1"]
      @ds.resource.display_label.should == ["Document"]
      @ds.resource.resource_object_id.should == ["hull:3112a"]
      @ds.resource.resource_ds_id.should == ["content"]
      @ds.resource.diss_type.should == ["genericContent/content"]
      @ds.resource.file.file_id.should == ["content"]
      @ds.resource.file.format.should == ["pdf"]
      @ds.resource.file.mime_type.should == ["application/pdf"]
      @ds.resource.file.size.should == ["26349568"]
      @ds.resource.file.location.should == ["http://hydra.hull.ac.uk/assets/hull:3112a/genericContent/content"]
      @ds.resource.file.date_created.should == []
      @ds.resource.file.date_last_modified.should == []
      @ds.resource.file.date_last_accessed.should == []
      @ds.resource.file.checksum.should == []

      #Simple proxies
      @ds.content_url.should == ["http://hydra.hull.ac.uk/assets/hull:3112a/genericContent/content"]
      @ds.content_format.should == ["pdf"]
      @ds.content_mime_type.should == ["application/pdf"]
      @ds.content_size.should == ["26349568"]
    end
  end

  context "with a new ContentMetadata instance" do
    before(:each) do
      @content_metadata_ds = Hyhull::Datastream::ContentMetadata.new
    end

    describe ".new" do
      content_metadata =  Hyhull::Datastream::ContentMetadata.new
      content_metadata.to_xml == Hyhull::Datastream::ContentMetadata.xml_template.to_xml
    end

    describe "#resource_template" do
      it "should generate a new resource node" do
        node = Hyhull::Datastream::ContentMetadata.resource_template
        node.should be_kind_of(Nokogiri::XML::Element)

        node.to_xml.should be_equivalent_to('<resource sequence="" id="content" contains="content"  displayLabel="" objectID=""  serviceDef="" dsID="content" serviceMethod=""><file id="content" format="" mimeType="" size="" dateCreated="" dateLastModified="" dateLastAccessed=""><checksum type=""></checksum><location type="url"></location></file></resource>')

        node = Hyhull::Datastream::ContentMetadata.resource_template(:sequence=>'1', :display_label=>'Journal article', :object_id=>'hull-res:nnnn', :service_def=>'hull-sDef:journalArticle', :service_method=>'getContent', :mime_type=>'application/pdf', :format=>'pdf', :file_id =>'Filename.pdf', :checksum => '3efsdfsd3d', :checksum_type => 'md5')
      
        node.should be_kind_of(Nokogiri::XML::Element)
        node.to_xml.should be_equivalent_to('<resource sequence="1" id="content" contains="content" displayLabel="Journal article" objectID="hull-res:nnnn" serviceDef="hull-sDef:journalArticle" dsID="content" serviceMethod="getContent"><file id="Filename.pdf" mimeType="application/pdf" format="pdf" size="" dateCreated="" dateLastModified="" dateLastAccessed=""><checksum type="md5">3efsdfsd3d</checksum><location type="url"></location></file></resource>')
      end
    end

    describe "insert_resource" do
      it "should insert a new resource into the current instance, and then mark the datastream as changed" do
        @content_metadata_ds.resource.length.should == 0
        @content_metadata_ds.changed?.should be_false
        node, index = @content_metadata_ds.insert_resource
        @content_metadata_ds.changed?.should be_true

        @content_metadata_ds.resource.length.should == 1
        node.to_xml.should == Hyhull::Datastream::ContentMetadata.resource_template(:sequence=>"1").to_xml
        index.should == 0

        node, index = @content_metadata_ds.insert_resource
        @content_metadata_ds.resource.length.should == 2
        index.should == 1
      end
    end

    describe "remove_resource" do
      it "should remove the corresponding resource from the xml and then mark the datastream as changed" do
        @content_metadata_ds.insert_resource
        @content_metadata_ds.save
        @content_metadata_ds.resource.length.should == 1
        result = @content_metadata_ds.remove_resource("0")
        @content_metadata_ds.resource.length.should == 0
        @content_metadata_ds.changed.should be_true
      end
    end

  end 

end