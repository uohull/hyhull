require 'spec_helper'

describe HighwirePressMetaHelper do 

  let(:document) { Hash[
    "active_fedora_model_ssi", "JournalArticle",
    "title_tesim", ["The title of the Article"],
    "creator_name_ssim", ["Lamb Simon.", "Smith John."],
    "journal_publisher_ssm", ["Lamb Pub"],
    "journal_publication_date_ssm", ["2009-01-28"],
    "journal_title_ssm", ["Lamb"],
    "journal_volume_ssm", ["34"],
    "journal_issue_ssm", ["1"],
    "journal_start_page_ssm", ["234"],
    "journal_end_page_ssm", ["236"],
    "journal_print_issn_ssm", ["1234-1234"],
    "journal_electronic_issn_ssm", ["1234-1234X"],
    "subject_topic_ssm", ["Keyword 1", "Keyword 2"],
    "journal_article_doi_ssm", ["00.1234/s1212-123223y"],
    "resource_object_id_ssm", ["ObjectID", "ObjectID"],
    "resource_ds_id_ssm", ["Content", "DsID"],
    "sequence_ssm", ["2","1"]
  ] }


  describe ".meta_tags" do
    it "returns the expected citation_title meta tag" do
      tags = helper.meta_tags(document)
      expect(tags).to include('<meta content="The title of the Article" name="citation_title" />')
    end

    it "returns the expected citation_author meta tag" do
      tags = helper.meta_tags(document)
      expect(tags).to include('<meta content="Lamb Simon." name="citation_author" />')
      expect(tags).to include('<meta content="Smith John." name="citation_author" />')
    end

    it "returns the expected citation_date meta tag in the correct format of YYYY/MM/DD" do
      tags = helper.meta_tags(document)
      expect(tags).to include('<meta content="2009/01/28" name="citation_date" />')
    end

    it "returns the expected citation_publisher meta tag" do
      tags = helper.meta_tags(document)
      expect(tags).to include('<meta content="Lamb Pub" name="citation_publisher" />')
    end
 
    it "returns the expected citation_journal_title meta tag" do
      tags = helper.meta_tags(document)
      expect(tags).to include('<meta content="Lamb" name="citation_journal_title" />')
    end

    it "returns the expected citation_volume meta tag" do
      tags = helper.meta_tags(document)
      expect(tags).to include('<meta content="34" name="citation_volume" />')
    end

    it "returns the expected citation_issue meta tag" do
      tags = helper.meta_tags(document)
      expect(tags).to include('<meta content="1" name="citation_issue" />')
    end

    it "returns the expected citation_firstpage meta tag" do
      tags = helper.meta_tags(document)
      expect(tags).to include('<meta content="234" name="citation_firstpage" />')
    end

    it "returns the expected citation_lastpage meta tag" do
      tags = helper.meta_tags(document)
      expect(tags).to include('<meta content="236" name="citation_lastpage" />')
    end

    it "returns the expected citation_doi meta tag" do
      tags = helper.meta_tags(document)
      expect(tags).to include('<meta content="00.1234/s1212-123223y" name="citation_doi" />')
    end

    it "returns the expected citation_issn (both print and electronic)" do
      tags = helper.meta_tags(document)
      expect(tags).to include('<meta content="1234-1234" name="citation_issn" />')
      expect(tags).to include('<meta content="1234-1234X" name="citation_issn" />')
    end

    it "returns the expected citation_keywords meta tag in keyword; format" do
      tags = helper.meta_tags(document)
      expect(tags).to include('<meta content="Keyword 1; Keyword 2; " name="citation_keywords" />')
    end

    it "returns the expected pdf url (prime content - Sequence 1) of resource" do
      tags = helper.meta_tags(document)
      expect(tags).to include('<meta content="http://hydra.hull.ac.uk/resources/ObjectID/DsID" name="citation_pdf_url" />')
    end
  
  end
 
end

#     title: "title_tesim",
#     author: "creator_name_ssim",
#     date: "journal_publication_date_ssm",
#     publisher: "journal_publisher_ssm",
#     journal_title: "journal_title_ssm",
#     journal_volume: "journal_volume_ssm",
#     journal_issue: "journal_issue_ssm",
#     journal_start_page: "journal_start_page_ssm",
#     journal_end_page: "journal_end_page_ssm",
#     doi: "journal_article_doi_ssm",
#     print_issn: "journal_print_issn_ssm",
#     electronic_issn: "journal_electronic_issn_ssm",
#     keywords: "subject_topic_ssm"

#     <meta name=”citation_author” content=”Green, Richard A.” />
# <meta name=”citation_author” content=”Awre, Christopher L. />
# <meta name=”citation_date” content=”2007/07/23” /> (note slashes, not hyphens)
# <meta name=”citation_title” content=”
# The RepoMMan Project : Automating workflow and metadata for an institutional repository” />
# <meta name=”citation_publisher” content=”Emerald” /> (not ‘University of Hull’ for anything published formally)
# <meta name=”citation_journal_title” content=”OCLC Systems and Services” />
# <meta name=”citation_volume” content=”23” />
# <meta name=”citation_issue” content=”2” />
# <meta name=”citation_firstpage” content=”210” />
# <meta name=”citation_lastpage” content=”215” />
# <meta name=”citation_doi” content=”http://dx.doi.org/10.1108/10650750710748513” />
# <meta name=”citation_isbn” content=”978 1 84663 454 3” />
# <meta name=”citation_keywords” content=”Repositories; JISC; Project management; RepoMMan” />
# <meta name=”citation_language” content=”en” />
# <meta name=”citation_pdf_url” content=”https://hydra.hull.ac.uk/resources/hull:98/content” />