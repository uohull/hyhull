module Hyhull
  module Models 
    module SetTreeBehaviour
      extend ActiveSupport::Concern

      included do
        logger.info("Adding SetTreeBehaviour to the Hydra model")
      end

      module ClassMethods
        private 

        def build_tree(root_id, set_c_model)
          hits = retrieve_sets(set_c_model)
          sets = build_array_of_parents_and_children(root_id, hits)  
          root_node = build_children(Hyhull::Models::SetTree.new(root_id, "Root set"), sets)
        end

        def retrieve_sets(set_c_model)
          fields = "has_model_ssim:#{set_c_model}"
          options = {:fl=>["id", "title_ssm", "is_member_of_ssim", "active_fedora_model_ssim"], :rows=>10000, :sort=>"system_create_dtsi asc" }
          ActiveFedora::SolrService.query(fields,options)
        end

        def build_array_of_parents_and_children(root_id, hits)
          pids = hits.map {|hit| hit["id"] }
          sets = hits.each.inject({}) do |hash,hit|
            if hit["id"] != root_id
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

        def build_children node, nodes
          if nodes.fetch(node.name,nil)
            nodes[node.name][:children].each do |child|
              title = if child["title_ssm"].nil? then "No title defined" else child["title_ssm"].first end          
              child_node = Hyhull::Models::SetTree.new(child["id"], title)
              node << build_children(child_node, nodes)
            end
          end
          node
        end
      end

    end
  end
end

