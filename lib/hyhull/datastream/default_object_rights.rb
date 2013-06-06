module Hyhull
  module Datastream
    # Hyhull implementation of DefaultObjectRights follows the standard RightsMetadata DS model but doesn't need indexing
    # TODO Move to hydra-head implementation PolicyObject behaviour
    class DefaultObjectRights < Hydra::Datastream::RightsMetadata

      set_terminology do |t|
        t.root(:path=>"rightsMetadata", :xmlns=>"http://hydra-collab.stanford.edu/schemas/rightsMetadata/v1", :schema=>"http://github.com/projecthydra/schemas/tree/v1/rightsMetadata.xsd") 
        t.copyright {
          ## BEGIN possible delete, justin 2012-06-22
          t.machine {
            t.cclicense   
            t.license     
          }
          t.human_readable(:path=>"human")
          t.license(:proxy=>[:machine, :license ])            
          t.cclicense(:proxy=>[:machine, :cclicense ])                  
          ## END possible delete

          t.title(:path=>'human', :attributes=>{:type=>'title'})
          t.description(:path=>'human', :attributes=>{:type=>'description'})
          t.url(:path=>'machine', :attributes=>{:type=>'uri'})
        }
        t.access do
          t.human_readable(:path=>"human")
          t.machine {
            t.group
            t.person
          }
          t.person(:proxy=>[:machine, :person])
          t.group(:proxy=>[:machine, :group])
          # accessor :access_person, :term=>[:access, :machine, :person]
        end
        t.discover_access(:ref=>[:access], :attributes=>{:type=>"discover"})
        t.read_access(:ref=>[:access], :attributes=>{:type=>"read"})
        t.edit_access(:ref=>[:access], :attributes=>{:type=>"edit"})
        # A bug in OM prevnts us from declaring proxy terms at the root of a Terminology
        # t.access_person(:proxy=>[:access,:machine,:person])
        # t.access_group(:proxy=>[:access,:machine,:group])
        
        t.embargo {
          t.human_readable(:path=>"human")
          t.machine{
            t.date(:type =>"release")
          }
          t.embargo_release_date(:proxy => [:machine, :date])
        }    

        t.license(:ref=>[:copyright])
      end

      #Overrides to_solr to remove indexing of this DS
      def to_solr(obj)
        obj
      end
    end
  end
end