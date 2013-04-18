module Hyhull::ModsMetadataMethods
  extend ActiveSupport::Concern

  included do
    logger.info("Adding Hyhull::ModsMetadataMethods to the model")
  end


  module ClassMethods
    #Overrides the pid_namespace method to use hull NS
    def person_relator_terms
      {
        "aut" => "Author",
        "cre" => "Creator",
        "edt" => "Editor",
        "phg" => "Photographer",  
        "mdl" => "Module leader",
        "spr" => "Sponsor",
        "sup" => "Supervisor"     
      }
    end

    def person_role_terms
      ["Author", "Creator", "Editor", "Photographer", "Module leader", "Sponsor", "Supervisor"]
    end

    def organisation_role_terms
      [ "Creator", "Host", "Sponsor"]
    end

    def qualification_name_terms
      ["PhD", "ClinPsyD", "MD", "PsyD", "MA" , "MEd", "MPhil", "MRes", "MSc" , "MTheol", "EdD" , "DBA", "BA", "BSc"]  
    end

    def qualification_level_terms
      ["Doctoral", "Masters", "Undergraduate"]
    end

    def dissertation_category_terms
      ["Blue", "Green", "Red"]
    end

  end

end