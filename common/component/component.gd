## A global utility class for managing [BaseComponent] registration and access.
class_name Component


## Returns true if the given [param node] has a registered component of type
## [param component_type]. [br]
##
## [param component_type] should be an object instance or a class reference to any type
## that extends [BaseComponent].
static func has_component(node: Node, component_type: Variant) -> bool:
  if not node:
    return false;

  return node.has_meta(TypeString.from(component_type));


## Registers the given [param component] to [param node] using the component's class name
## as the metadata key. [br]
##
## [param component] should be an object instance of any type that extends [BaseComponent].
static func set_component(node: Node, component: BaseComponent) -> void:
  if not node:
    return;

  # Note: Saving a String instead of a NodePath is a work-around for metadata getting
  # stuck to nodes in the editor, but it loses the editor's grasp on persistent paths.
  # For example, renaming a node will auto-update a NodePath but not a String.
  node.set_meta(TypeString.from(component), node.get_path_to(component));


## Returns the [param component_type] registered to [param node], or null. [br]
##
## [param component_type] should be an object instance or a class reference to any type
## that extends [BaseComponent].
static func get_component(node: Node, component_type: Variant) -> BaseComponent:
  if not node:
    push_error("Cannot get a component from a null value.");
    return null;

  var node_path: String = node.get_meta(TypeString.from(component_type));
  return node.get_node(node_path);


## Returns a filtered list of all [param component_type] objects held by [param nodes].
## Note that this means the returned list of components may be empty even when
## [param nodes] is not. [br]
##
## [param component_type] should be an object instance or a class reference to any type
## that extends [BaseComponent].
static func get_all(nodes: Array, component_type: Variant) -> Array[BaseComponent]:
  var components: Array[BaseComponent];

  for node in nodes:
    if (
        node is not Node
        or not has_component(node, component_type)
    ):
      continue;
    components.append(get_component(node, component_type));

  return components;


## Removes the [param component_type] registered to [param node], or if no component
## exists, does nothing. [br]
##
## [param component_type] should be an object instance or a class reference to any type
## that extends [BaseComponent].
static func remove_component(node: Node, component_type: Variant) -> void:
  if not node:
    return;

  node.remove_meta(TypeString.from(component_type));
