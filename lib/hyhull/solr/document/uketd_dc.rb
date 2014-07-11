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
    [:contributor, :coverage, :creator, :format, :identifier, :relation, :rights, :source, :subject, :title, :type]
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
       xml.tag!("dc:language", self.language_code, "xsi:type" => "dcterms:ISO6392") unless self.language_code.nil? 
       xml.tag! "uketdterms:institution", institution unless institution.nil?
       xml.tag! "uketdterms:department", department unless department.nil?  
     end
    xml.target!
  end

  alias_method :export_as_xml, :export_as_uketd_dc_xml

end


# <uketd_dc:uketddc xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
#                   xmlns:dc="http://purl.org/dc/elements/1.1/"
#                   xmlns:dcterms="http://purl.org/dc/terms/"
#                   xmlns:uketd_dc="http://naca.central.cranfield.ac.uk/ethos-oai/2.0/"
#                   xmlns:uketdterms="http://naca.central.cranfield.ac.uk/ethos-oai/terms/">
#    <dc:title>An investigation of the factors which influence the degree of patient involvement in the physiotherapeutic consultation</dc:title>
#    <dc:creator>Green, Angela Jane</dc:creator>
#    <uketdterms:advisor>Klaber Moffett, Jennifer (Supervisor)</uketdterms:advisor>
#    <uketdterms:advisor>Sharp, Donald (Supervisor)</uketdterms:advisor>
#    <uketdterms:sponsor>Hull and East Yorkshire Hospitals NHS Trust (Sponsor)</uketdterms:sponsor>
#    <dcterms:issued>2008-04</dcterms:issued>
#    <dc:subject>Medicine</dc:subject>
#    <dcterms:abstract>The term patient involvement is widely used within the physiotherapy vocabulary, yet it is poorly defined and understood. Little is known about NHS physiotherapists’ attitudes, knowledge or skills regarding patient involvement. The aims of this thesis were therefore to: &#xD;
# i) identify the attributes which define the concept of patient involvement in physiotherapy using a method of concept analysis; &#xD;
# ii) investigate physiotherapists’ attitudes towards the involvement of patients by means of a national survey; &#xD;
# iii) explore patients’ attitudes towards their involvement in the physiotherapy consultation using a local survey; &#xD;
# iv) explore physiotherapists’ ability to recognise effective practice in patient involvement by means of a regional study using video vignettes of simulated consultations; &#xD;
# v) ascertain to what extent physiotherapists involve patients in their physiotherapy care by means of an in-depth local observational study.&#xD;
# </dcterms:abstract>
#    <dc:date>2008-10-06</dc:date>
#    <dc:format xsi:type="dcterms:IMT">video/x-ms-wmv</dc:format>
#    <dc:language xsi:type="dcterms:ISO6392">eng</dc:language>
#    <dc:type>Thesis or dissertation</dc:type>
#    <uketdterms:qualificationlevel>Doctoral</uketdterms:qualificationlevel>
#    <uketdterms:qualificationname>PhD</uketdterms:qualificationname>
#    <uketdterms:institution>The University of Hull</uketdterms:institution>
#    <uketdterms:department>Postgraduate Medical Institute</uketdterms:department>
#    <dc:rights>© 2008 Angela Jane Green. All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holder.</dc:rights>
#    <dcterms:isReferencedBy xsi:type="dcterms:URI">http://hydra.hull.ac.uk/resources/hull:756</dcterms:isReferencedBy>
#    <dc:identifier xsi:type="dcterms:URI">/assets/hull:756d/datastreams/content</dc:identifier>
# </uketd_dc:uketddc>