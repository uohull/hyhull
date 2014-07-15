# -*- encoding : utf-8 -*-
require 'builder'

# This module provide Dublin Core export based on the document's semantic values
module Hyhull::Solr::Document::UketdDc
  def self.extended(document)
    # Register our exportable formats
    Hyhull::Solr::Document::UketdDc.register_export_formats( document )
  end

  def self.register_export_formats(document)
    document.will_export_as(:xml)
    document.will_export_as(:uketd_dc_xml, "text/xml")
  end

  def dc_field_names
    [:contributor, :coverage, :creator, :identifier, :relation, :rights, :source, :subject, :title, :type]
  end

  def uketd_terms_field_names
    [:advisor, :sponsor, :qualificationlevel, :qualificationname, :institution, :department]
  end

  def dc_terms_field_names
    [:issued, :abstract]
  end

  # In ETD resources the institution is contained in a combined field publisher
  # Eg. "Department of Chemistry, The Univerity of Hull"  - will return "The University of Hull"
  def institution
    return publisher.include?(",") ? publisher.split(",").last.strip : ""  unless publisher.nil? 
  end

  def department
    return publisher.include?(",") ? publisher.split(",").first.strip : "" unless publisher.nil? 
  end

  def publisher
    if self.to_semantic_values.include? :publisher
      return self.to_semantic_values[:publisher].first
    end
  end

  def mime_type
    unless self.main_asset.nil?
      return self.main_asset[:mimetype]
    end
  end


  # dublin core elements are mapped against the #dublin_core_field_names whitelist.
  def export_as_uketd_dc_xml
    xml = Builder::XmlMarkup.new
    xml.tag!("uketd_dc:uketddc",
             'xmlns:oai_dc' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
             'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
             'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
             'xmlns:dcterms' => "http://purl.org/dc/terms/",
             'xmlns:uketd_dc' => "http://naca.central.cranfield.ac.uk/ethos-oai/2.0/",
             'xmlns:uketdterms' => "http://naca.central.cranfield.ac.uk/ethos-oai/terms/",
             'xsi:schemaLocation' => %{http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd}) do
       self.to_semantic_values.select { |field, values| dc_field_names.include? field.to_sym }.each do |field,values|
         values.each do |v|
           xml.tag! 'dc:' + field.to_s, v
         end
       end
       xml.tag! "dc:date", self.to_semantic_values[:date_created].first unless self.to_semantic_values[:date_created].first.nil? 
       self.to_semantic_values.select { |field, values| dc_terms_field_names.include? field.to_sym }.each do |field,values|
         values.each do |v|
           xml.tag! 'dcterms:' + field.to_s, v
         end
       end
      self.to_semantic_values.select { |field, values| uketd_terms_field_names.include? field.to_sym }.each do |field,values|
         values.each do |v|
           xml.tag! 'uketdterms:' + field.to_s, v
         end
       end
       xml.tag!("dcterms:isReferencedBy", self.full_resource_uri, "xsi:type" => "dcterms:URI") unless self.full_resource_uri.nil? 
       xml.tag!("dc:identifier", self.main_asset_uri, "xsi:type" => "dcterms:URI") unless self.main_asset_uri.nil? 
       xml.tag!("dc:format", mime_type, "xsi:type" => "dcterms:IMT") unless mime_type.nil? 
       xml.tag!("dc:language", self.language_code, "xsi:type" => "dcterms:ISO6392") unless self.language_code.nil? 
       xml.tag! "uketdterms:institution", institution unless institution.nil?
       xml.tag! "uketdterms:department", department unless department.nil?  
     end
    xml.target!
  end

  alias_method :export_as_xml, :export_as_uketd_dc_xml

end
