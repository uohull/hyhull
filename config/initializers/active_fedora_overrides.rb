# The following code represents hull-specific overrides to ActiveFedora. 
module ActiveFedora
  class ContentModel < Base  

    ### Serialize class names with first letter downcased
    def self.sanitized_class_name(klass)
      #Do not downcase FileAsset 
      if klass.name != "FileAsset"
        class_name = klass.name.gsub(/(::)/, '_')
        class_name[0,1].downcase + class_name[1..-1]
      else
          klass.name.gsub(/(::)/, '_')
      end      
    end

  end
end