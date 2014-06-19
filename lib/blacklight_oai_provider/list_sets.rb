module BlacklightOaiProvider
  
  class ListSets < OAI::Provider::Response::Base
    
    def to_xml
      raise OAI::SetException.new unless provider.model.sets

      response do |r|
        r.ListSets do
          provider.model.sets.each do |set|
            r.set do
              r.setSpec set.get("oai_set_spec_ssim")
              r.setName set.get("oai_set_name_ssim")
              r.setDescription(set.description) if set.respond_to?(:description)
            end
          end
        end
      end
    end

  end  

end
