require 'tree'
class Hyhull::Models::SetTree < Tree::TreeNode
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