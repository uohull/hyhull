module Hyhull
  module Datastream
    class WorkflowProperties < ActiveFedora::OmDatastream

      set_terminology do |t|
        t.root(:path=>"fields")
        t.depositor
        t.depositorEmail
        t.collection
        t.state      
      end

      # Generates an empty contentMetadata
      def self.xml_template
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.fields {}
        end

        return builder.doc
      end

    end
  end
end

