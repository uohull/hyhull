module Hyhull
  module Services
    class TextExtractionService
      def self.extract_text(file_content, mime_type)
        begin
          if self.valid_content_types.include? mime_type

            solr_base_url = Blacklight.solr_config[:url] ? Blacklight.solr_config[:url] : Blacklight.solr_config["url"] ? Blacklight.solr_config["url"] : Blacklight.solr_config[:fulltext] ? Blacklight.solr_config[:fulltext]["url"] : Blacklight.solr_config[:default]["url"] 
            solr_text_extraction_url = "#{solr_base_url}/update/extract?extractOnly=true&wt=ruby&extractFormat=text"

            uri = URI(solr_text_extraction_url)

            http = Net::HTTP.new(uri.host, uri.port)

            # Set username/password if configured in SOLR URL
            username = uri.user.nil? ? "" : uri.user
            password = uri.password.nil? ? "" : uri.password

            request = Net::HTTP::Post.new(uri.request_uri, { "Content-type" => "#{mime_type};charset=utf-8", "Content-Length" => "#{file_content.size}" })
            request.body = file_content
            request.basic_auth(username, password) unless username.empty? && password.empty?

            response = http.request(request)
            text = eval(response.body)[""].strip

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