# Meant to be applied on top of SolrDocument to implement
# methods required by the ruby-oai provider
module Hyhull::OAI::Provider::BlacklightOaiProvider::SolrDocumentExtension
  # Used to store OAI:set membership
  attr_accessor :sets

  # This is required to ensure that OAI-OMH can retrieve system_modified date
  def system_modified_dtsi
   Time.parse get('system_modified_dtsi')
  end

  def to_oai_dc
    export_as('oai_dc_xml')
  end

  def to_uketd_dc
    export_as("uketd_dc_xml")
  end

end