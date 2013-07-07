module Hyhull
  module Models
    module StructuralSetAncestryBehaviour      
        extend ActiveSupport::Concern
        
        module ClassMethods
          @@ancestors=[]

          def ancestry pid
            @@ancestors = []
            create_set_members_array pid     
            @@ancestors.flatten! 
          end

          def create_set_members_array pid        
            unless pid.nil? 
              hits = retrieve_set_members escape_colon(pid)
              if hits.length > 0 
                @@ancestors << hits 
                hits.each do |hit|
                  create_set_members_array hit["id"] if hit["active_fedora_model_ssi"] == "StructuralSet"
                end
              end
            end
          end

          def retrieve_set_members pid
            fields = "is_member_of_ssim:info\\:fedora\\/" + pid
            options = {:fl=>["id", "title_ssm", "is_member_of_ssim", "active_fedora_model_ssi"], :rows=>10000, :sort=>"system_create_dtsi asc" }
            ActiveFedora::SolrService.query(fields,options)
          end

          def escape_colon str
            str.gsub(/[:]/,  '\\:') 
          end
        end

        # Returns a hash of all mathching/non-matching permissions ancestors of self
        # @returns e.g. {:match => [{:id => test:1, :active_fedora_model_ssi => StructuralSet }, :dont_match => [{id => test:5, :active_fedora_model_ssim => StructuralSet}]}
        def match_ancestors_default_object_rights
          match = []
          dont_match = []

          children = self.class.ancestry self.pid
          rights_ds = Hydra::Datastream::RightsMetadata.new(self.inner_object, "defaultObjectRights")

          unless children.nil?
            children.each do |child|
              child_instance = ActiveFedora::Base.find(child["id"], cast: true)
              if is_published? child_instance 
                if child_instance.is_a? StructuralSet
                  ds_id = "defaultObjectRights"
                else
                  ds_id = "rightsMetadata"
                end
                    
                object_match = compare_object_with_rights({:object=>child_instance, :ds_id=>ds_id } , rights_ds)
                 
                if object_match
                  match << {:id => child["id"], :active_fedora_model_ssi => child["active_fedora_model_ssi"] }
                else
                  dont_match << {:id => child["id"], :active_fedora_model_ssi => child["active_fedora_model_ssi"] }
                end
              end     
            end
          end
          return {:match => match, :dont_match => dont_match}
        end

        # Updates all the ancestors permissions that match with the parent permissions
        # @permission_params permission_params ex “group”=>{“group1”=>“discover”,“group2”=>“edit”, “person”=>“person1”=>“read”,“person2”=>“discover”}
        def update_ancestors_permissions permission_params
          children = match_ancestors_default_object_rights
          unless children.nil?
            matched_children = children[:match]

            unless matched_children.nil?
              matched_children.each do |child|

                id = child[:id]
                resource = ActiveFedora::Base.find(id, cast: true)

                if resource.kind_of? StructuralSet
                  ds_id = "defaultObjectRights"
                else
                  ds_id = "rightsMetadata"
                end
                # Manually update the permissions of the child_resource
                # Don't rely on the update_permissions_from_apo callback...         
                resource.update_resource_permissions(permission_params, ds_id)                
                resource.save
              end
            end
          end
        end


        # Updates all the ancestors permissions that match with the parent permissions
        # @permission_params permission_params ex “group”=>{“group1”=>“discover”,“group2”=>“edit”, “person”=>“person1”=>“read”,“person2”=>“discover”}
        def update_ancestors_permissions_from_apo
          ancesters_updated = true        
          updated = []
          not_updated = []

          children = match_ancestors_default_object_rights
          unless children.nil?
            matched_children = children[:match]

            unless matched_children.nil?
              matched_children.each do |child|

                id = child[:id]
                resource = ActiveFedora::Base.find(id, cast: true)

                if resource.kind_of? StructuralSet
                  # Call apply_defaultObjectRights on the structuralset
                  # This copies the default rights across..
                   resource.apply_defaultObjectRights                 
                else
                  #Rely on the fact that the parent APO is up to date...
                  resource.apply_permissions = true                 
                end

                # Save the resource changes...
                if resource.save
                  updated << resource.id 
                else
                  ancesters_updated = false
                  not_updated << resource.id
                end

              end
            end
          end

          return ancesters_updated, {:updated => updated, :not_updated => not_updated}
        end

        # Not elegant, but will check if the particularly object is published
        # published objects within hyhull will be marked with the resource_state = published 
        def is_published? obj
          if obj.respond_to?("resource_state") && obj.respond_to?("resource_published?")
            obj.resource_published?
          else
            # if the object does not contain resource_state, we will assume that it is a published un-queued object
            true 
          end
        end

        # Compare an object rightsMetadata with another rights ds
        # object={:object => ActiveFedora:Base, :ds_id => "rightsMetadata"}
        # rights= Hydra::Datastream::RightsMetadata.new(self.inner_object, "defaultObjectRights/rightsMetadata/etc..")
        def compare_object_with_rights(object, rights)    
          instance = object[:object]
          ds_id  = object[:ds_id]

          ds = Hydra::Datastream::RightsMetadata.new(instance.inner_object, ds_id)  
          ds.groups == rights.groups
        end

        private :update_ancestors_permissions, :is_published?, :compare_object_with_rights

      end
  end
end