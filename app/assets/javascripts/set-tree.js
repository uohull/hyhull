/* BuildTree
 * The Method will use the tree.jquery.js (http://mbraak.github.io/jqTree/#jqtree) to build a tree for the sets
 * tree_div should be the target div for the tree ie. '#tree-div'
 * tree_date - JSON representation of the tree
 * self_id - the identifier of self in the tree ie. 'hull:123'
 * selected_id - the identifier of the currently selected parent ie. 'hull:rootSet'
 * set_name_target - A text box id to place the selected tree item name
 */
function BuildTree(tree_div, tree_data, self_id, selected_id, set_name_target) {
  $(tree_div).tree({
    data: tree_data
  })

  if (self_id.length > 0) {
    var node_to_remove = $(tree_div).tree('getNodeById', self_id);
    if (typeof node_to_remove != "undefined") {
      $(tree_div).tree('removeNode', node_to_remove);        
    }
  }

  if (selected_id.length > 0) {
    var node = $(tree_div).tree('getNodeById', selected_id);
    $(tree_div).tree('selectNode', node);

    if (set_name_target.length > 0) {
      $(set_name_target).val(node.name); 
    }     
  }

}

/* SelectSet
 * The method retrieves the selected element from the tree and places the selected id and
 * name into the appropiate text fields.
 * tree_div should be the target div for the tree ie. '#tree-div'
 * set_id_target - A hidden/text id to place the selected tree item id
 * set_name_target - A text box id to place the selected tree item name
 * modal_id - a modal identifier (if passed in the method will close the modal popup)
 */
function SelectSet(tree_div, set_name_target, set_id_target, modal_id) {
  var node = $(tree_div).tree('getSelectedNode');

  if (node) {
    $(set_name_target).val(node.name);
    $(set_id_target).val(node.id);

    if (modal_id.length > 0) {
      $(modal_id).modal('hide');
    }   
  }
  else {
    alert("Please select a set");
  }
}