require 'spec_helper'

describe SearchOptimisationMetaHelper do 
  # Test is using the standard configuration with rails.root/config/meta_tag_solr_mappings.rb

  context("JournalArticle") do

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
      it "returns the expected dc.Title meta tag" do
        tags = helper.meta_tags(document)
        expect(tags).to include('<meta content="The title of the Article" name="dc.Title" />')
      end

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
        expect(tags).to include('<meta content="2009/01/28" name="citation_publication_date" />')
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
        expect(tags).to include('<meta content="Keyword 1; Keyword 2" name="citation_keywords" />')
      end

      it "returns the expected pdf url (prime content - Sequence 1) of resource" do
        tags = helper.meta_tags(document)
        expect(tags).to include('<meta content="http://hydra.hull.ac.uk/resources/ObjectID/DsID" name="citation_pdf_url" />')
      end
    
    end
  end


  context("UketdObject") do

    let(:document) { Hash[
      "active_fedora_model_ssi", "UketdObject",
      "title_tesim", ["The title of the ETD"],
      "creator_name_ssim", ["Smith, Peter"],
      "publisher_ssm", ["Department A, The University of Hull"],
      "date_issued_ssm", ["2012-01"],  
      "subject_topic_ssm", ["ETD Keyword 1", "ETD Keyword 2"],
      "resource_object_id_ssm", ["Test:123a", "Test:123b"],
      "resource_ds_id_ssm", ["content", "content"],
      "sequence_ssm", ["2","1"]
    ] }

    describe ".meta_tags" do
      before(:each) do
        helper.stub(:meta_tag_solr_mappings) { meta_tag_solr_mappings }
      end

      it "returns the expected dc.Title meta tag" do
        tags = helper.meta_tags(document)
        expect(tags).to include('<meta content="The title of the ETD" name="dc.Title" />')
      end

      it "returns the expected citation_title meta tag" do      
        tags = helper.meta_tags(document)
        expect(tags).to include('<meta content="The title of the ETD" name="citation_title" />')
      end

      it "returns the expected citation_author meta tag" do
        tags = helper.meta_tags(document)
        expect(tags).to include('<meta content="Smith, Peter" name="citation_author" />')
      end

      it "returns the expected citation_date meta tag in the correct format of YYYY rather than YYYY-MM (as in metadata)" do
        tags = helper.meta_tags(document)
        expect(tags).to include('<meta content="2012" name="citation_publication_date" />')
      end

      it "returns the expected citation_publisher meta tag" do
        tags = helper.meta_tags(document)
        expect(tags).to include('<meta content="Department A, The University of Hull" name="citation_publisher" />')
      end

      it "returns the expected citation_keywords meta tag" do
        tags = helper.meta_tags(document)
        expect(tags).to include('<meta content="ETD Keyword 1; ETD Keyword 2" name="citation_keywords" />')
      end

      it "returns the expected pdf url (prime content - Sequence 1) of resource" do
        tags = helper.meta_tags(document)
        expect(tags).to include('<meta content="http://hydra.hull.ac.uk/resources/Test:123b/content" name="citation_pdf_url" />')
      end

      it "returns the citation_dissertation_institution as the The University of Hull when it exists within the Publisher field" do
        tags = helper.meta_tags(document)
        expect(tags).to include('<meta content="The University of Hull" name="citation_dissertation_institution" />')
      end
    end

  end

  context("GenericContent - Report") do

    let(:document) { Hash[
      "active_fedora_model_ssi", "GenericContent",
      "title_tesim", ["The title of the Report"],
      "creator_name_ssim", ["Smith, Peter"],
      "publisher_ssm", ["Department B, The University of Hull"],
      "genre_ssm", ["Report"]
    ] }

    describe ".meta_tags" do
      it "returns the expected dc.Title meta tag" do
        tags = helper.meta_tags(document)
        expect(tags).to include('<meta content="The title of the Report" name="dc.Title" />')
      end

      it "returns the expected citation_title meta tag" do      
        tags = helper.meta_tags(document)
        expect(tags).to include('<meta content="The title of the Report" name="citation_title" />')
      end

      it "returns the expected citation_author meta tag" do
        tags = helper.meta_tags(document)
        expect(tags).to include('<meta content="Smith, Peter" name="citation_author" />')
      end

          it "returns the expected citation_publisher meta tag" do
        tags = helper.meta_tags(document)
        expect(tags).to include('<meta content="Department B, The University of Hull" name="citation_publisher" />')
      end

      it "returns the citation_technical_report_institution as the The University of Hull when it exists within the Publisher field" do
        tags = helper.meta_tags(document)
        expect(tags).to include('<meta content="The University of Hull" name="citation_technical_report_institution" />')
      end
    end

  end

end
