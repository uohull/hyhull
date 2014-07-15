# -*- encoding : utf-8 -*-
require 'builder'

# This module provide Dublin Core export based on the document's semantic values
module Hyhull::Solr::Document::DublinCore
  def self.extended(document)
    # Register our exportable formats
    Blacklight::Solr::Document::DublinCore.register_export_formats( document )
  end

  def self.register_export_formats(document)
    document.will_export_as(:xml)
    document.will_export_as(:dc_xml, "text/xml")
    document.will_export_as(:oai_dc_xml, "text/xml")
  end

  def dublin_core_field_names
    [:coverage, :creator, :date, :format, :identifier, :publisher, :relation, :rights, :source, :subject, :title, :type]
  end

  def contributors
    contributors = []

    advisors = get_semantic_value_of :advisor
    sponsors = get_semantic_value_of :sponsor

    contributors.concat(advisors.collect {|v| "#{v} (Supervisor)"}) unless advisors.nil? 
    contributors.concat(sponsors.collect {|v| "#{v} (Sponsor)"}) unless sponsors.nil? 

    contributors
  end

  def extent
    unless self.main_asset.nil?  
      if self.main_asset.include?(:size) && !main_asset[:size].nil?    
        return Hyhull::Utils::StringFormatting.get_friendly_file_size(main_asset[:size])
      end
    end
  end

  # dublin core elements are mapped against the #dublin_core_field_names whitelist.
  def export_as_oai_dc_xml
    xml = Builder::XmlMarkup.new
    xml.tag!("oai_dc:dc",
             'xmlns:oai_dc' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
             'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
             'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
             'xmlns:dcterms' => "http://purl.org/dc/terms/",
             'xsi:schemaLocation' => %{http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd}) do
       self.to_semantic_values.select { |field, values| dublin_core_field_names.include? field.to_sym }.each do |field,values|
         values.each do |v|
           xml.tag! 'dc:' + field.to_s, v
         end
       end
       xml.tag!("dc:description", self.description) unless self.description.nil? 
       xml.tag!("dc:type", self.resource_type) unless self.resource_type.nil? 
       xml.tag!("dc:format", self.mime_type, "xsi:type" => "dcterms:IMT") unless mime_type.nil?
       xml.tag!("dc:format", self.extent, "xsi:type" => "dcterms:extent") unless extent.nil?  
       xml.tag!("dc:identifier", self.main_asset_uri, "xsi:type" => "dcterms:URI") unless self.main_asset_uri.nil?
       xml.tag!("dc:language", self.language_code, "xsi:type" => "dcterms:ISO6392") unless self.language_code.nil? 

       self.contributors.each do |v|
         xml.tag! "dc:contributors", v
       end 

     end
    xml.target!
  end

  alias_method :export_as_xml, :export_as_oai_dc_xml
  alias_method :export_as_dc_xml, :export_as_oai_dc_xml

  private

  def get_semantic_value_of(key)
    self.to_semantic_values[key] if self.to_semantic_values.include? key
  end 

end
