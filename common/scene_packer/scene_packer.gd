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

  _set_owner(node, node);

  var scene := PackedScene.new();
  var status := scene.pack(node);

  assert(status == OK,
    "Status code %s given while packing node: %s" % [status, node_path]);

  _set_owner(node, original_owner);
  return scene;


## Recursively set the [param owner] for [param node] and all its children.
static func _set_owner(node: Node, owner: Node) -> void:
  for child in node.get_children():
    child.owner = owner;
    _set_owner(child, owner);
