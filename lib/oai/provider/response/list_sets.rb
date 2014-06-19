module OAI::Provider::Response
  
  class ListSets < Base
    
    def to_xml
      raise OAI::SetException.new unless provider.model.sets

      response do |r|
        r.ListSets do
          provider.model.sets.each do |set|
            debugger
            r.set do
              r.setSpec set.first.docs.first["oai_set_spec_ssim"].first
              r.setName set.first.docs.first["oai_set_name_ssim"].first
              r.setDescription(set.description) if set.respond_to?(:description)
            end
          end
        end
      end
    end

  end  

end
