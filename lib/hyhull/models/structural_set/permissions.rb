module Hyhull
  module Models  
    module StructuralSet
      module Permissions

        extend ActiveSupport::Concern
        #we're overriding the permissions= method which is in RightsMetadata
        include Hydra::ModelMixins::RightsMetadata

        included do
          before_create :set_rightsMetadata, :apply_defaultObjectRights

          has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata
          has_metadata name: "defaultObjectRights", label: "Default object rights", type: Hyhull::Datastream::DefaultObjectRights

        end


        # Set the visibility of the DefaultObjectRights 
        # Note the original version of this changed the rightsMetadata datastream
        # however for StructuralSets we only allow the defaultObjectRights to be set.. 
        def set_visibility(visibility)
          # only set explicit permissions
          case visibility
          when "open"
            self.datastreams["defaultObjectRights"].permissions({:group=>"public"}, "read")
          when "uoh"
            self.datastreams["defaultObjectRights"].permissions({:group=>["staff", "student"]}, "read")
            self.datastreams["defaultObjectRights"].permissions({:group=>"public"}, "none")
          when "uoh_staff"
            self.datastreams["defaultObjectRights"].permissions({:group=>"staff"}, "read")
            self.datastreams["defaultObjectRights"].permissions({:group=>"public", :group=>"student"}, "none")
          when "uoh_student"
            self.datastreams["defaultObjectRights"].permissions({:group=>"student"}, "read")
            self.datastreams["defaultObjectRights"].permissions({:group=>"public", :group=>"staff"}, "none")
          when "restricted" 
            self.datastreams["defaultObjectRights"].permissions({:group=>"student"}, "none")
            self.datastreams["defaultObjectRights"].permissions({:group=>"staff"}, "none")
            self.datastreams["defaultObjectRights"].permissions({:group=>"public"}, "none")
          end
        end

        ## Updates those permissions that are provided to it. Does not replace any permissions unless they are provided
        def permissions=(params)
          perm_hash = permission_hash
          #params[:new_user_name].each { |name, access| perm_hash['person'][name] = access } if params[:new_user_name].present?
          params[:new_group_name].each { |name, access| perm_hash["group"][name] = access } if params[:new_group_name].present?

          #params[:user].each { |name, access| perm_hash['person'][name] = access} if params[:user]
          params[:group].each { |name, access| perm_hash["group"][name] = access} if params[:group]

          update_permissions(perm_hash, 'defaultObjectRights')
        end

        ## Copied from Hydra::ModelMixins::RightsMetadata
        ## Changed to return DefaultObjecrRights
        ## Returns a list with all the permissions on the object.
        # @example
        #  [{:name=>"group1", :access=>"discover", :type=>'group'},
        #  {:name=>"group2", :access=>"discover", :type=>'group'},
        #  {:name=>"user2", :access=>"read", :type=>'user'},
        #  {:name=>"user1", :access=>"edit", :type=>'user'},
        #  {:name=>"user3", :access=>"read", :type=>'user'}]
        def permissions
          (defaultObjectRights.groups.map {|x| {:type=>'group', :access=>x[1], :name=>x[0] }} + 
            defaultObjectRights.individuals.map {|x| {:type=>'user', :access=>x[1], :name=>x[0]}})
        end
    
        # All stuctural_sets at present get their rightsMetadata from hull-apo:structuralSet
        def set_rightsMetadata
          admin_policy_obj = self.class.find("hull-apo:structuralSet")
          raise "Unable to find hull-apo:structuralSet" unless admin_policy_obj
          self.apo = admin_policy_obj
          apply_rights_metadata_from_apo
        end

        # Method for updating the permissions on the set. If the permissions are changing on the defaultObjectRights, ancestors will need updating...
        # @permission_params permission_params ex “group”=>{“group1”=>“discover”,“group2”=>“edit”, “person”=>“person1”=>“read”,“person2”=>“discover”}
        # @ds_id ds_id specify the rights datastream (usually rightsMetadata or defaultObjectRights)
        def update_permissions(permission_params, ds_id)
          #If changing defaultObjectRights we need to change the children...
          if ds_id == "defaultObjectRights"
            update_ancestors_permissions permission_params
          end
          #update the parents
          update_resource_permissions(permission_params, ds_id)
        end

        # Inherit the defaultObjectRights from the set's parent. 
        def apply_defaultObjectRights
          raise "Unable to find parent. Cannot apply defaultObjectRights" unless parent
          defaultRights = Hyhull::Datastream::DefaultObjectRights.new(self.inner_object, 'defaultObjectRights')
          Hydra::Datastream::RightsMetadata.from_xml(parent.datastreams["defaultObjectRights"].content, defaultRights)
          self.datastreams["defaultObjectRights"] = defaultRights if self.datastreams.has_key? "defaultObjectRights" 
        end

        private

        def permission_hash
          old_perms = self.permissions
          user_perms =  {}
          old_perms.select{|r| r[:type] == 'user'}.each do |r|
            user_perms[r[:name]] = r[:access]
          end
          user_perms
          group_perms =  {}
          old_perms.select{|r| r[:type] == 'group'}.each do |r|
            group_perms[r[:name]] = r[:access]
          end
          {'person'=>user_perms, 'group'=>group_perms}
        end

      end
    end
  end
end