namespace :hyhull do
  
  namespace :ref do

    task :process_files => :environment do
      csv_path = ENV["CSV_PATH"]

      import = ManifestImport.new(csv_path)
      output_report_path = import.process_csv

      puts "Complete"
      puts "Report of import is available at: #{output_report_path}"
     end

  end

end

require 'csv'
class ManifestImport
  attr_accessor :csv_path

  def initialize(csv_path)
    @csv_path = csv_path
  end

  def process_csv
    import_status = {}

    csv = CSV.read(csv_path, { col_sep: "|", headers: true, return_headers: true})

    csv.each do |output|

      unless output.header_row?
        puts "Processing output id #{output["id"]}"

        resource_id = nil
        errors = nil
        output_id = output["id"].to_s

        if import_status.has_key?(output_id)
           errors  = "Output has already been imported into Fedora, this may row may contain an additional author, or an additiona file that will need adding manually (Please see the original csv)"
           output_id = "#{output_id}-duplicate"  
        else
          model, message = model_instance_by_publication_type(output["publication_type"])    

          if model

           # general fields          
            model.title = remove_ctrl_chars_from_string(output["title"])  unless output["title"].to_s.empty?  
            model.publisher = "The University of Hull"
            add_keywords_to_resource(model, remove_ctrl_chars_from_string(output["keywords"]))
            add_authors_to_resource(model, remove_ctrl_chars_from_string(output["authors"]), output["author_first_name"], output["author_last_name"])

            # journal article
            if model.class == JournalArticle
              model.abstract = clean_abstract(output["abstract"]) unless output["abstract"].to_s.empty? 
              model.journal_publication_date =  format_date(output["publication_date"]) unless output["publication_date"] .to_s.empty? 
              model.journal_title = output["journal_name"] unless output["journal_name"].to_s.empty? 
              model.journal_publisher = output["publisher"] unless output["publisher"].to_s.empty? 
              model.journal_print_issn = output ["issn"] unless output["issn"].to_s.empty? 
              model.journal_article_doi = output["doi"] unless output["doi"].to_s.empty? 
              model.journal_volume = output["journal_volume"] unless output["journal_volume"].to_s.empty? 
              model.journal_issue = output["journal_issue"] unless output["journal_issue"].to_s.empty? 
              model.journal_start_page = output["start_page"] unless output["start_page"].to_s.empty? 
              model.journal_end_page = output["end_page"] unless output["end_page"].to_s.empty? 
              model.peer_reviewed = peer_reviewed?(output["peer_reviewed"]).to_s unless output["peer_reviewed"].to_s.empty? 
           else
              # generic content derived
              model.description = clean_abstract(output["abstract"]) unless output["abstract"].to_s.empty?
              model.date_issued = format_date(output["publication_date"]) unless output["publication_date"].to_s.empty? 
            end
            # Need to add doi to generic content model (authored book examples)
            # Need to add ISBN to generic content model
            # Need to add start and end page to generic content model (book chapter example)   - Journal volume??? Check with Chris
            # Conference contribution has a journal name... hmmm
            # other forms have a journal name issue number,  start page, end page etc...
            # book chapter
            # authored book
            #dataset

            assign_permissions_to_rights(model)   

            saved  = false  
            begin 
              saved = model.save
            rescue Exception => e
               errors = "An unexpected error was thrown when trying to save this resource.  Stack: #{e.to_s}"
            end 
            
             if saved
                resource_id = model.id
                unless output["relative_file_path"].to_s.empty?
                   begin 
                     success, message = add_file_to_resource(model, full_file_path(output["relative_file_path"]), output["original_filename"])                  
                      unless success 
                         errors  = message.empty? ? "Problem adding file to resource" : message
                      end
                   rescue
                      errors = "Problem adding file to resource"
                   end                 
                end
              else
                errors = "Resource failed to save, error reported: #{model.errors.messages.to_s}"
              end

            else
              errors = "Hydra model not found for output"
            end
        end
        import_status.merge!(output_id => { hydra_resource_id: resource_id.to_s, error: errors.to_s } )
      end
    end

    
    report_path = write_status_to_csv(import_status)

    return report_path

  end

  def write_status_to_csv(import_status)
     target_path = "#{csv_folder_path}/import-report.csv"

     CSV.open(target_path, "wb") do |csv|
       csv << ["Output ID", "Hydra resource id", "Error"]

        import_status.each_pair do |key, value|
          output_id = key
          hydra_resource_id = value[:hydra_resource_id]
          error = value[:error]
          csv << [output_id, hydra_resource_id, error]
        end
     end
      return target_path
  end

  def model_instance_by_publication_type(publication_type)
    default_params = { namespace: "ref-test" }
    case publication_type.downcase
      when "authored book"
         return GenericContent.new(default_params.merge(genre: "Book")), ""
      when "chapter in book"
         return GenericContent.new(default_params.merge(genre: "Book chapter")), ""
      when "composition"
        return GenericContent.new(default_params.merge(genre: "Sound")), "Defaulting to GenericContent - Sound - Check genre"
      when "conference contribution"
        return GenericContent.new(default_params.merge(genre: "Conference paper or abstract")), ""
      when "digital and visual media"
        return GenericContent.new(default_params.merge(genre: "Sound")) , ""
       when "edited book"
         return GenericContent.new(default_params.merge(genre: "Book")), ""
       when "journal article"
         return JournalArticle.new(default_params), ""
       when "internet publication"
         return GenericContent.new(default_params.merge(genre: "Generic content")), "Defaulting to GenericContent - Generic content - Check genre"
       when "other form of assessable output"
         return GenericContent.new(default_params.merge(genre: "Generic content")), "Defaulting to GenericContent - Generic content - Check genre"
      when "research dataset / database"
         return Dataset.new(default_params), ""
      when "research report (for external body)"
         return GenericContent.new(default_params.merge(genre: "Report")), ""
      when "scholarly edition"
         return GenericContent.new(default_params.merge(genre: "Book")), ""
      else 
        return nil,  "No match found"
     end
  end


  def add_authors_to_resource(resource, author_list, author_first_name, author_last_name)
    authors = authors_as_array(author_list, author_first_name, author_last_name)

    resource.person_name = []
    resource.person_role_text = []

    # Add authors...
    unless authors.empty?
      resource.descMetadata.add_names(authors,Array.new(authors.size) { "Author" }, "person")
    end
  end

  def add_keywords_to_resource(resource, keywords) 
    # if no keywords, add placeholder
    if !keywords.nil? && !keywords.empty?
      resource.subject_topic  = split_into_array(keywords)
    else
       resource.subject_topic = ["Subject topic goes here"]
    end
  end

  def add_file_to_resource(resource, file_path, original_filename)
  if File.exists?(file_path)                        
      file_data = create_uploaded_file(original_filename, file_path)
      success, file_assets, message = resource.add_file_content(file_data)
      return success, ""               
  else
      return false, "File does not exist at specified path"
  end
end



  def peer_reviewed?(peer_reviewed)
    peer_reviewed.downcase.eql?("yes") ? true : false 
  end

  def split_into_array(string)
    array = string.include?(",") ? string.split(",").map { |k| k.strip } : string.include?(";") ? string.split(";").map { |k| k.strip } : [string] 
    array.delete_if{|i| i.strip == "" } 
  end

  # Adds the prime author to the display
  def authors_as_array(author_list, prime_author_first_name, prime_author_last_name)
      full_author_list =  author_list.to_s.empty? ? [] :  author_list.split(",").map { |a| a.strip }
      # returns Lamb S from Simon Lamb
      author_to_match = "#{prime_author_last_name} #{prime_author_first_name[0]}"      
      full_author_list.delete_if{|a| a.include?(author_to_match) }

      author_to_add = "#{prime_author_last_name}, #{prime_author_first_name}"
      full_author_list.unshift(author_to_add)      

      full_author_list.delete_if{|i| i.strip == "" } 
 
       return full_author_list
  end

  def create_uploaded_file(original_filename, file_path)
     mime_type = mime_type(file_path)

     if original_filename.to_s() == ""
       original_filename =  file_path[file_path.rindex('/')+1.. -1]
     end

     mime_type = mime_type(file_path)
     file = ActionDispatch::Http::UploadedFile.new({ :filename => original_filename, :type =>mime_type, :tempfile => File.new(file_path) })
  end

  # Utilises Ruby on rails method..
  def mime_type(file_path)
    begin
      return MIME::Types.type_for(file_path).first.content_type
    rescue
      return "application/octet-stream"
    end
  end

  def full_file_path(relative_file_path)
    file_path = "#{csv_folder_path}/#{relative_file_path}"
  end 


  def csv_folder_path
    File.dirname(@csv_path)
  end

  def format_date(date_string)
    begin
      return Date.parse(date_string).strftime('%F')
    rescue
      return  ""
    end
  end

  def assign_permissions_to_rights(model)    
    rights_ds = model.datastreams["rightsMetadata"]
    rights_ds.permissions({:group=>default_group}, 'edit') unless rights_ds.nil?
  end

  def default_group
    "contentAccessTeam"
  end

  def clean_abstract(string)
    string.nil? ? "" : string.gsub(1.chr, "").gsub(3.chr, "")
  end

  def remove_ctrl_chars_from_string(string)
    string.nil? ? "" : string.gsub(10.chr, " ").gsub(13.chr, " ").gsub(12.chr, " ").gsub(1.chr, "").gsub(3.chr, "")
  end


end


class Hello
  def self.speak
  end
end