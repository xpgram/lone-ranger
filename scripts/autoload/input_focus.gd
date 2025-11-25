extends Node


## Returns true if the given node is, or is an ancestor of, the currently focused control
## node.
func has_branch_focus(node: Node) -> bool:
  var focus_owner := get_viewport().gui_get_focus_owner();

  if not focus_owner:
    return false;
  elif node is Control and (node as Control).has_focus():
    return true;

  return node.is_ancestor_of(focus_owner);
