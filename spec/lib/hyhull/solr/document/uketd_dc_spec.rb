# encoding: UTF-8
require "spec_helper"

class TestSolrDocumentClass
  include Blacklight::Solr::Document
  include Hyhull::Solr::DocumentExt

  field_semantics.merge!(    
                         :title => "title_tesim",
                         :creator => "creator_name_ssim",
                         :language => "language_text_ssm",
                         :description => "abstract_ssm",
                         :abstract => "abstract_ssm",
                         :subject => "subject_topic_ssm",
                         :date => "date_issued_ssm",
                         :issued => "date_issued_ssm",
                         :format => "format",                         
                         :type => "genre_ssm",
                         :identifier => "id",
                         :rights => "rights_ssm",
                         :publisher => "publisher_ssm",
                         :qualificationlevel => "qualification_level_ssm",
                         :qualificationname => "qualification_name_ssm",
                         :advisor => "supervisor_name_ssm",
                         :sponsor => "sponsor_name_ssm"
                         )
  use_extension( Hyhull::Solr::Document::UketdDc)

end

describe Hyhull::Solr::Document::UketdDc do

  let(:solr_response) do
    ActiveSupport::HashWithIndifferentAccess.new({"system_create_dtsi"=>"2011-02-23T10:50:50Z", "system_modified_dtsi"=>"2014-06-19T13:24:29Z", "object_state_ssi"=>"A", "active_fedora_model_ssi"=>"UketdObject", "id"=>"hull:3500", "object_profile_ssm"=>["{\"datastreams\":{\"RELS-EXT\":{\"dsLabel\":\"Fedora Object-to-Object Relationship Metadata\",\"dsVersionID\":\"RELS-EXT.0\",\"dsCreateDate\":\"2011-02-23T10:50:50Z\",\"dsState\":\"A\",\"dsMIME\":\"application/rdf+xml\",\"dsFormatURI\":\"info:fedora/fedora-system:FedoraRELSExt-1.0\",\"dsControlGroup\":\"X\",\"dsSize\":963,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"hull:3500+RELS-EXT+RELS-EXT.0\",\"dsLocationType\":null,\"dsChecksumType\":\"DISABLED\",\"dsChecksum\":\"none\"},\"properties\":{\"dsLabel\":\"Workflow properties\",\"dsVersionID\":\"properties.0\",\"dsCreateDate\":\"2013-02-18T23:10:13Z\",\"dsState\":\"A\",\"dsMIME\":\"text/xml\",\"dsFormatURI\":null,\"dsControlGroup\":\"X\",\"dsSize\":194,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"hull:3500+properties+properties.0\",\"dsLocationType\":null,\"dsChecksumType\":\"DISABLED\",\"dsChecksum\":\"none\"},\"DC\":{\"dsLabel\":\"DC Metadata\",\"dsVersionID\":\"DC.0\",\"dsCreateDate\":\"2011-02-23T10:50:50Z\",\"dsState\":\"A\",\"dsMIME\":\"text/xml\",\"dsFormatURI\":\"http://www.openarchives.org/OAI/2.0/oai_dc/\",\"dsControlGroup\":\"X\",\"dsSize\":3072,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"hull:3500+DC+DC.0\",\"dsLocationType\":null,\"dsChecksumType\":\"DISABLED\",\"dsChecksum\":\"none\"},\"contentMetadata\":{\"dsLabel\":\"Content metadata\",\"dsVersionID\":\"contentMetadata.1\",\"dsCreateDate\":\"2011-03-28T23:23:27Z\",\"dsState\":\"A\",\"dsMIME\":\"text/xml\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":434,\"dsVersionable\":false,\"dsInfoType\":null,\"dsLocation\":\"hull:3500+contentMetadata+contentMetadata.1\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"DISABLED\",\"dsChecksum\":\"none\"},\"descMetadata\":{\"dsLabel\":\"MODS Metadata\",\"dsVersionID\":\"descMetadata.3\",\"dsCreateDate\":\"2013-11-26T22:42:05Z\",\"dsState\":\"A\",\"dsMIME\":\"text/xml\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":4780,\"dsVersionable\":false,\"dsInfoType\":null,\"dsLocation\":\"hull:3500+descMetadata+descMetadata.3\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"DISABLED\",\"dsChecksum\":\"none\"},\"rightsMetadata\":{\"dsLabel\":\"Rights metadata\",\"dsVersionID\":\"rightsMetadata.0\",\"dsCreateDate\":\"2011-02-23T10:50:50Z\",\"dsState\":\"A\",\"dsMIME\":\"text/xml\",\"dsFormatURI\":null,\"dsControlGroup\":\"X\",\"dsSize\":962,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"hull:3500+rightsMetadata+rightsMetadata.0\",\"dsLocationType\":null,\"dsChecksumType\":\"DISABLED\",\"dsChecksum\":\"none\"},\"UKETD_DC\":{\"dsLabel\":\"UKETD_DC Metadata\",\"dsVersionID\":\"UKETD_DC.0\",\"dsCreateDate\":\"2011-05-17T09:04:04Z\",\"dsState\":\"A\",\"dsMIME\":\"text/xml\",\"dsFormatURI\":null,\"dsControlGroup\":\"E\",\"dsSize\":0,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"http://localhost:8080/fedora/objects/hull:3500/methods/hull-sDef:uketdObject/getUKETDMetadata\",\"dsLocationType\":\"URL\",\"dsChecksumType\":\"DISABLED\",\"dsChecksum\":\"none\"}},\"objLabel\":\"The evolution of accounting in developing countries : the study of Jordan - Helles, Salem Abdalla Salem; \",\"objOwnerId\":\"fedoraAdmin\",\"objModels\":[\"info:fedora/hydra-cModel:commonMetadata\",\"info:fedora/hull-cModel:uketdObject\",\"info:fedora/hydra-cModel:genericParent\",\"info:fedora/fedora-system:FedoraObject-3.0\"],\"objCreateDate\":\"2011-02-23T10:50:50Z\",\"objLastModDate\":\"2014-06-19T13:24:29Z\",\"objDissIndexViewURL\":\"http://localhost:8983/fedora/objects/hull%3A3500/methods/fedora-system%3A3/viewMethodIndex\",\"objItemIndexViewURL\":\"http://localhost:8983/fedora/objects/hull%3A3500/methods/fedora-system%3A3/viewItemIndex\",\"objState\":\"A\"}"], "_resource_state_ssi"=>"published", "resource_object_id_ssm"=>["hull:3500a"], "resource_ds_id_ssm"=>["content"], "resource_display_label_ssm"=>["Document"], "content_format_ssm"=>["pdf"], "content_mime_type_ssm"=>["application/pdf"], "content_size_ssm"=>["22705152"], "sequence_ssm"=>["1"], "abstract_ssm"=>["The main purposes of this study are to ascertain whether Jordan's accounting systems (enterprise, government, social) provide the necessary information for its socio- economic development planning and to suggest means by which to improve accounting in the country.\n \nAn attempt is made to describe the Jordanian environment and to determine the possible orientation of accounting in Jordan. It is shown that Jordan is a developing country, which was and still is subject to pressure from foreign powers both politically and economically. This pressure has created a bias towards the U.K.! USA accounting systems. Laws and regulations, accounting education and the accounting profession, are oriented towards the accounting of these two countries.\n \nThe study of accounting development in Jordan revealed that public accounting has not reached the stage where it can be recognised as a developed profession. The empirical study revealed that the most important items needed to improve national accounting practices are as follows: (1) an active accounting organisation; (2) accounting principles suitable to the Jordanian environment; (3) official auditing pronouncements; and (4) a code of professional conduct.\n \nThe empirical survey revealed the inadequacy and unsuitability of current reporting practices to the needs of the local users of financial reports. It also identified the following as major problems facing accounting profession in Jordan: (1) shortage of qualified accountants; (2) weakness and underdevelopment of the Jordanian accounting curricula; and (3) lack of sufficiently qualified teaching staff.\n \nSeveral recommendations are made concerning the development of the accounting profession and education so they can meet the challenge of economic development. These recommendations call for improvement in accounting practices, organisation of the profession, coordination of efforts with government, and increase in contacts with accountants in other countries."], "genre_ssm"=>["Thesis or dissertation"], "qualification_level_ssm"=>["Doctoral"], "qualification_name_ssm"=>["PhD"], "rights_ssm"=>["© 1992 Salem Abdalla Salem Helles. All rights reserved. No part of this publication may be reproduced without the written permission of the copyright holder."], "creator_name_ssim"=>["Helles, Salem Abdalla Salem"], "supervisor_name_ssm"=>["Briston, R. J."], "sponsor_name_ssm"=>["University of Qatar", "Islamic University of Gaza"], "title_tesim"=>["The evolution of accounting in developing countries : the study of Jordan"], "subject_topic_ssm"=>["Management"], "date_issued_ssm"=>["1992-11"], "publisher_ssm"=>["Department of Accounting, The University of Hull"], "language_text_ssm"=>["English"], "person_name_ssm"=>["Helles, Salem Abdalla Salem", "Briston, R. J."], "person_role_text_ssm"=>["Creator", "Supervisor"], "organisation_name_ssm"=>["University of Qatar", "Islamic University of Gaza"], "organisation_role_text_ssm"=>["Sponsor", "Sponsor"], "edit_access_group_ssim"=>["contentAccessTeam"], "discover_access_group_ssim"=>["public"], "read_access_group_ssim"=>["public"], "is_member_of_ssim"=>["info:fedora/hull:3375"], "is_governed_by_ssim"=>["info:fedora/hull:3375"], "is_member_of_collection_ssim"=>["info:fedora/hull:ETDAccounting"], "has_model_ssim"=>["info:fedora/hydra-cModel:genericParent", "info:fedora/hydra-cModel:commonMetadata", "info:fedora/hull-cModel:uketdObject"], "sortable_date_dtsi"=>"1992-11-01T00:00:00Z", "timestamp"=>"2014-06-19T13:24:30.314Z"})
  end

  let(:test_document_instance) do
    # We instantiate a test SolrDocument class with the same field_semantics defined
    TestSolrDocumentClass.new(solr_response)
  end

   # Solr response contains the publisher "Department of Accounting, The University of Hull" 
  describe ".institution" do
    it "will be derived from the publisher where the format is compatable" do
       expect(test_document_instance.institution).to eq "The University of Hull"
    end
  end

  describe ".department" do
    it "will be derived from the publisher where the format is compatable" do
      expect(test_document_instance.department).to eq "Department of Accounting"
    end
  end

  # TODO Add test to check xml
  describe ".export_as_xml" do
    it "will be derived from the publisher where the format is compatable" do
      xml = test_document_instance.export_as_xml
    end
  end

end