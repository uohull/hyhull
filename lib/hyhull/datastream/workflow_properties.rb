module Hyhull
  module Datastream
    class WorkflowProperties < ActiveFedora::OmDatastream

      set_terminology do |t|
        t.root(:path=>"fields")
        t.depositor
        t.depositor_email(:path=>'depositorEmail')
        t.collection
        t._resource_state(:path=>'resourceState')
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

