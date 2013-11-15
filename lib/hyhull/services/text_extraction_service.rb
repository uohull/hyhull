module Hyhull
  module Services
    class TextExtractionService
      def self.extract_text(file_content, mime_type)
        begin
          if self.valid_content_types.include? mime_type
            url = Blacklight.solr_config[:url] ? Blacklight.solr_config[:url] : Blacklight.solr_config["url"] ? Blacklight.solr_config["url"] : Blacklight.solr_config[:fulltext] ? Blacklight.solr_config[:fulltext]["url"] : Blacklight.solr_config[:default]["url"] 
            uri = URI(url+'/update/extract?&extractOnly=true&wt=ruby&extractFormat=text')
            req = Net::HTTP.new(uri.host, uri.port)
            resp = req.post(uri.to_s, file_content, {'Content-type'=>mime_type+';charset=utf-8', "Content-Length"=>"#{file_content.size}" })
            text = eval(resp.body)[""].strip
            return text
          else
            raise "The mime_type is not a valid content type for text extraction"
          end 
        rescue Exception => e
          raise "An exception was thrown when trying to extract the text from the file_content: " + e.message
        end
      end

      def self.valid_content_types
        return ["application/pdf", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"]
      end

    end 
  end
end