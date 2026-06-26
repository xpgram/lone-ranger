## @static [br]
## A utility script to aid in UI focus management.
class_name InputFocus


## Returns true if [param node] is, or is an ancestor of, the currently focused control
## node. [br]
##
## In combination with [method Control.accept_input], this is an effective means of
## letting input events bubble up the scene tree, but only from focused child to parent.
static func has_branch_focus(node: Node) -> bool:
  if not node:
    return false;

  if node is Control and (node as Control).has_focus():
    return true;

  var focus_owner := node.get_viewport().gui_get_focus_owner();
  return node.is_ancestor_of(focus_owner);


## If [param node] is, or is an ancestor of, the currently focused control node, releases
## focus on the focused node.
static func release_branch_focus(node: Node) -> void:
  if not node or not has_branch_focus(node):
    return;

  var focus_owner := node.get_viewport().gui_get_focus_owner();
  focus_owner.release_focus();
