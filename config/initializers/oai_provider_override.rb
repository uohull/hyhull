# RecordResponse#identifier_for overridden in order to use ":" seperator instead of the default "/"  - The "/" causes oai_identifier validation issues
module OAI::Provider::Response
  class RecordResponse < Base
    private

    def identifier_for(record)
      "#{provider.prefix}:#{record.id}"
    end

  end
end

#  Removed the r.setDescription as we haven't currently implemented the return of oai_dc as part of the setDescription element.  
#  An empty <setDescription/> tag causes oai validation issues
module OAI::Provider::Response  
  class ListSets < Base
    
    def to_xml
      raise OAI::SetException.new unless provider.model.sets

      response do |r|
        r.ListSets do
          provider.model.sets.each do |set|
            r.set do
              r.setSpec set.spec
              r.setName set.name
              #r.setDescription(set.description) if set.respond_to?(:description)
            end
          end
        end
      end
    end

  end  

end
