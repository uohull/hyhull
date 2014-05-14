# Meta_tag_solr_mappings configuration 
# This configuration file can be used to specify the mappings between solr fields and meta_tag mappings.
# These can be customised based upon the resource_type_field i.e. active_fedora_model_ssi
# The available meta fields are title, author, date, publisher,journal_title,journal_issue,
#    journal_start_page, journal_end_page, doi, print_issn, electronic_issn, isbn, keywords
META_TAG_SOLR_MAPPINGS =  {
  resource_type_field: "active_fedora_model_ssi",

  JournalArticle: { 
    title: "title_tesim",
    author: "creator_name_ssim",
    date: "journal_publication_date_ssm",
    publisher: "journal_publisher_ssm",
    journal_title: "journal_title_ssm",
    journal_volume: "journal_volume_ssm",
    journal_issue: "journal_issue_ssm",
    journal_start_page: "journal_start_page_ssm",
    journal_end_page: "journal_end_page_ssm",
    doi: "journal_article_doi_ssm",
    print_issn: "journal_print_issn_ssm",
    electronic_issn: "journal_electronic_issn_ssm",
    keywords: "subject_topic_ssm"
  },
  Default: { 
    title: "title_tesim",
    author: "creator_name_ssim",
    keywords: "subject_topic_ssm",
    publisher: "publisher_ssm",
    date: "date_issued_ssm"
  }
}

