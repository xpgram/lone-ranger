## A global utility class for managing [BaseComponent] registration and access.
class_name Component


## Returns true if the given [param node] has a registered component of type
## [param component_type]. [br]
##
## [param component_type] should be a class reference to any type that extends
## [BaseComponent].
static func has_component(node: Node, component_type: Variant) -> bool:
  return node.has_meta(TypeString.from(component_type));


## Registers the given [param component] to [param node] using the component's class name
## as the metadata key.
static func set_component(node: Node, component: BaseComponent) -> void:
  node.set_meta(TypeString.from(component), component);


## Returns the [param component_type] registered to [param node], or null. [br]
##
## [param component_type] should be a class reference to any type that extends
## [BaseComponent].
static func get_component(node: Node, component_type: Variant) -> BaseComponent:
  return node.get_meta(TypeString.from(component_type));


## Removes the [param component_type] registered to [param node], or if no component
## exists, does nothing. [br]
##
## [param component_type] should be a class reference to any type that extends
## [BaseComponent].
static func remove_component(node: Node, component_type: Variant) -> void:
  node.remove_meta(TypeString.from(component_type));
