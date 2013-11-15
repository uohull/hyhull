require 'spec_helper'

describe Hyhull::Services::TextExtractionService do

  describe "extract_text" do
    before(:each) do
      pdf = fixture("hyhull/files/test_content.pdf")
      @pdf_contents = pdf.read  
  
      docx = fixture("hyhull/files/test_docx.docx")
      @docx_contents = docx.read
  	end
    it "should extract the text from the content of a pdf" do
      extracted_text = subject.class.extract_text(@pdf_contents, "application/pdf")  
      extracted_text.should match(/This is a dummy thesis for demonstration purposes \n\n \n\nOption aperiri ei per, eos tale evertitur vituperatoribus ut, vim eius quaestio tractatos id. Facer \n\ndiceret omnesque eam et, in modus incorrupte pri. Sea elitr iudicabit ne. Ut pri aperiam apeirian, ex \n\nubique voluptua torquatos mei. \n\n \n\nUsu at ullum vocent, et dicant graece cotidieque vim. Semper invenire at cum. Ad adhuc invenire his, \n\net eum aliquid deserunt nominati./)
    end
    it "should extract the text from the content of a word doc" do
      extracted_text = subject.class.extract_text(@docx_contents, "application/vnd.openxmlformats-officedocument.wordprocessingml.document") 
      extracted_text.should match(/This is a sample Word document.\n\nThis is a test./)
    end
    it "should throw an error when it is called with a non supported mimetype" do
      expect { subject.class.extract_text(@docx_contents, "image/jpeg")}.to raise_error 
    end
  end
end