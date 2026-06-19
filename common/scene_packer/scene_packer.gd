## A utility class to streamline the creation of [PackedScene]'s at runtime.
class_name ScenePacker

## @nullable
##
## Given a [param node], creates a [PackedScene] and returns it.
## Will return null if [param node] is null.
static func pack(node: Node) -> PackedScene:
  if not node:
    return null;

  var node_path := node.get_path();
  var original_owner := node.owner;

  _set_owner(node, node, original_owner);

  var scene := PackedScene.new();
  var status := scene.pack(node);

  assert(status == OK,
    "Status code %s given while packing node: %s" % [status, node_path]);

  _set_owner(node, original_owner, node);
  return scene;


## Recursively set the owner of all children of [param node] to [param new_owner]
## if they share the [param from_owner].
static func _set_owner(node: Node, new_owner: Node, from_owner: Node) -> void:
  for child in node.get_children():
    if child.owner != from_owner:
      continue;
    child.owner = new_owner;
    _set_owner(child, new_owner, from_owner);
