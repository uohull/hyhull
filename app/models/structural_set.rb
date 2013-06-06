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
    root_node = build_children(StructuralSetTree.new("Root set", "info:fedora/hull:rootSet"), sets)
  end

  private

  def self.retrieve_structural_sets
    all_hits = find_with_conditions({})
    hits = all_hits.map { |result|  {"id" => result["id"], "is_member_of_ssim" => result["is_member_of_ssim"], "title_ssm" => result["title_ssm"] } }
  end

  def self.structural_set_pids
    retrieve_structural_sets.map {|hit| "info:fedora/#{hit["id"]}" }
  end

  def self.build_array_of_parents_and_children hits
    pids = hits.map {|hit| "info:fedora/#{hit["id"]}" }
    sets = hits.each.inject({}) do |hash,hit|
      if hit["id"] != "hull:rootSet"
        parent_pid = hit["is_member_of_ssim"].first if hit.fetch("is_member_of_ssim",nil)
        if parent_pid && pids.include?( parent_pid )
          hash[parent_pid] = {:children=>[]} unless hash[parent_pid]
          hash[parent_pid][:children] << hit
        end
      end
      hash
    end
  end

  def self.build_children node, nodes
    if nodes.fetch(node.content,nil)
      nodes[node.content][:children].each do |child|
        title = if child["title_ssm"].first.nil? then "No title defined" else child["title_ssm"].first end          
        child_node = StructuralSetTree.new(title,"info:fedora/#{child["id"]}")
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

  def unordered_list(options=[],level=0)
    
  end  
end