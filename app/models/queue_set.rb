require 'tree'
# Model for a Queue 
class QueueSet < StructuralSet
  belongs_to :parent, property: :is_member_of, :class_name => "QueueSet"
end