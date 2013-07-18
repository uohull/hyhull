module Hyhull
  module Models  
    module Permissions

      extend ActiveSupport::Concern
      #we're overriding the permissions= method which is in RightsMetadata
      include Hydra::ModelMixins::RightsMetadata

      included do
        before_create :set_rightsMetadata
        has_metadata name: "rightsMetadata", label: "Rights metadata" , type: Hydra::Datastream::RightsMetadata
      end

      ## Updates those permissions that are provided to it. Does not replace any permissions unless they are provided
      ## An overriden version of the permissions= method (with the added option of specifying permission_ds)
      def set_permissions(params, permissions_ds)
        # default to rightsMetadata (like standard Hydra) if permissions_ds isn't set
        permissions_ds = "rightsMetadata" if permissions_ds.to_s == ""
        perm_hash = permission_hash
        #params[:new_user_name].each { |name, access| perm_hash['person'][name] = access } if params[:new_user_name].present?
        params[:new_group_name].each { |name, access| perm_hash["group"][name] = access } if params[:new_group_name].present?

        #params[:user].each { |name, access| perm_hash['person'][name] = access} if params[:user]
        params[:group].each { |name, access| perm_hash["group"][name] = access} if params[:group]

        update_permissions(perm_hash, permissions_ds)
      end

      ## An overridden version of the def permissions method, with the added option of specifying the permissions_ds
      # Note an class implementing this module should redirect def 'permissions' => 'get_permissions'
      def get_permissions permissions_ds
        # default to rightsMetadata (like standard Hydra) if permissions_ds isn't set
        permissions_ds = "rightsMetadata" if permissions_ds.to_s == ""
        (datastreams[permissions_ds].groups.map {|x| {:type=>'group', :access=>x[1], :name=>x[0] }} + 
          datastreams[permissions_ds].individuals.map {|x| {:type=>'user', :access=>x[1], :name=>x[0]}})

        (datastreams[permissions_ds].groups.map {|x| {:type=>'group', :access=>x[1], :name=>x[0] }} + 
          datastreams[permissions_ds].individuals.map {|x| {:type=>'user', :access=>x[1], :name=>x[0]}})
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