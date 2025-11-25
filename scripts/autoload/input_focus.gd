extends Node


## Returns true if [param node] is, or is an ancestor of, the currently focused control
## node. [br]
##
## In combination with [method Control.accept_input], this is an effective means of
## letting input events bubble up the scene tree, but only from focused child to parent.
func has_branch_focus(node: Node) -> bool:
  var focus_owner := get_viewport().gui_get_focus_owner();

  if not focus_owner:
    return false;
  elif node is Control and (node as Control).has_focus():
    return true;

  return node.is_ancestor_of(focus_owner);


## If [param node] is, or is an ancestor of, the currently focused control node, releases
## focus on the focused node.
func release_branch_focus(node: Node) -> void:
  if not has_branch_focus(node):
    return;
  
  var focus_owner := get_viewport().gui_get_focus_owner();
  focus_owner.release_focus();
