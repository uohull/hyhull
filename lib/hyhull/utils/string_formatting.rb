module Hyhull
  module Utils
    class StringFormatting
    # A class for adding useful String formatting methods ie. File size/date formatters

      def self.get_friendly_file_size(bytes)
        begin 
          bytes_fl = Float(bytes)
          text = bits_to_human_readable(bytes_fl).to_s
        rescue ArgumentError
          text = ""
        end
        text
      end

      # Pass through a string date in the format of YYYY-MM-DD/YYYY-MM/YYYY and it will return a human readable version
      def self.display_friendly_date(date)
        display_date = date
        begin
          if date.match(/^\d{4}-\d{2}$/)
            display_date = Date.parse(to_long_date(date)).strftime("%B") + " " + Date.parse(to_long_date(date)).strftime("%Y")
          elsif date.match(/^\d{4}-\d{2}-\d{2}$/)
            display_date = Date.parse(date).day().to_s + " " + Date.parse(date).strftime("%B") + " " + Date.parse(date).strftime("%Y")
          end
        rescue
          # Just rescue an issue with parsing the date...
        end         
        return display_date
      end

     private 

     def self.bits_to_human_readable(num)
       ['bytes','KB','MB','GB','TB'].each do |x|
        if num < 1024.0 || x == "TB"
         return "#{num.to_i} #{x}"
        else
         num = num/1024.0
         end
        end
      end

      #Utility method used to get long version of a date (YYYY-MM-DD) from short form (YYYY-MM) - Defaults 01 for unknowns - Exists in hull_model_methods too
      def self.to_long_date(flexible_date)
        full_date = ""
        if flexible_date.match(/^\d{4}$/)
          full_date = flexible_date + "-01-01"
        elsif flexible_date.match(/^\d{4}-\d{2}$/)
          full_date = flexible_date + "-01"
        elsif flexible_date.match(/^\d{4}-\d{2}-\d{2}$/)
          full_date = flexible_date
        end
        return full_date
      end

    end
  end
end