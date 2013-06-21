require 'tree'

# Model for a StructuralSet 
class StructuralSet < ActiveFedora::Base
  include Hyhull::Models::StructuralSet

  # Override the Hyhull:ModelMethods
  # Adds metadata about the depositor to the asset
  # Most important behavior: This version will NOT set rightsMetadata based on user_id (this is handled by set_rightsMetadata)
  # @param [String, #user_key] depositor
  #
  def apply_depositor_metadata(depositor, depositor_email)
    prop_ds = self.datastreams["properties"]

    depositor_id = depositor.respond_to?(:user_key) ? depositor.user_key : depositor
  
    if prop_ds
      prop_ds.depositor = depositor_id unless prop_ds.nil?
      prop_ds.depositor_email = depositor_email unless prop_ds.nil?
    end
    
    return true
  end

  def self.tree
    hits = retrieve_structural_sets
    sets = build_array_of_parents_and_children(hits)  
    root_node = build_children(StructuralSetTree.new("hull:rootSet", "Root set"), sets)
  end

  private

  def self.retrieve_structural_sets
    fields = "has_model_ssim:info\\:fedora\\/hull-cModel\\:structuralSet"
    options = {:fl=>["id", "title_ssm", "is_member_of_ssim", "active_fedora_model_ssim"], :rows=>10000, :sort=>"system_create_dtsi asc" }
    ActiveFedora::SolrService.query(fields,options)
  end

  def self.structural_set_pids
    retrieve_structural_sets.map {|hit| "info:fedora/#{hit["id"]}" }
  end

  def self.build_array_of_parents_and_children hits
    pids = hits.map {|hit| hit["id"] }
    sets = hits.each.inject({}) do |hash,hit|
      if hit["id"] != "hull:rootSet"
        parent_uri = hit["is_member_of_ssim"].first if hit.fetch("is_member_of_ssim",nil)
        # Change info:fedora/hull:1234 => hull:1234
        parent_pid = parent_uri[parent_uri.index("/") + 1..-1] if parent_uri

        if parent_pid && pids.include?( parent_pid )
          hash[parent_pid] = {:children=>[]} unless hash[parent_pid]
          hash[parent_pid][:children] << hit
        end
      end
      hash
    end
  end

  def self.build_children node, nodes
    if nodes.fetch(node.name,nil)
      nodes[node.name][:children].each do |child|
        title = if child["title_ssm"].nil? then "No title defined" else child["title_ssm"].first end          
        child_node = StructuralSetTree.new(child["id"], title)
        node << build_children(child_node, nodes)
      end
    end
    node
  end
end

class StructuralSetTree < Tree::TreeNode
  def options_for_nested_select(options=[],level=0)
    if is_root?
      pad = ''
    else
      pad = ('-' * (level - 1) * 2) + '--'
    end
    options <<  ["#{pad}#{name}", "#{content}"]

    #Sort the children - defaults on name sort
    children.sort! if !children.nil?
    children { |child| child.options_for_nested_select(options,level + 1)}
    options
  end

  def to_json
    super.gsub("content", "label").gsub("name", "id")
  end

  def unordered_list(options=[],level=0)
    
  end  
end