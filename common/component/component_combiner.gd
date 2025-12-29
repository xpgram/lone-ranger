## @tool [br]
##
## A [BaseComponent] utility node that combines the configuration for a set of components.
## This is useful, for instance, to create "component folders" in the scene tree without
## also having to set the ownership override for each individual component. [br]
##
## Example:
## [codeblock]
## Player2D
## ┠╴ComponentCombiner
## ┃ ┠╴HPComponent
## ┃ ┖╴InventoryComponent
## ┖╴Camera2D
## [/codeblock]
@tool
class_name ComponentCombiner
extends Node


## Emitted when this component's owner is altered.
signal component_owner_changed(new_owner: Node);


@export_group('Owner')

## A reference to a remote composite node for this component. This overrides the default
## composite node, which would be this node's direct parent.
@export var _remote_component_owner: Node:
  set(value):
    _remote_component_owner = value;
    component_owner_changed.emit(get_component_owner());


func _enter_tree() -> void:
  if not _remote_component_owner:
    component_owner_changed.emit(get_component_owner());


## Returns the [Node] this object is a component to. [br]
##
## Will return null if this node is the scene root while [member _remote_component_owner]
## is not set.
func get_component_owner() -> Node:
  return (
    _remote_component_owner if _remote_component_owner
    else get_parent()
  );


## Returns either the [param node] given, or if [param node] is a special component proxy
## type, returns the registration target at the end of the [code]owner->owner->owner[/code]
## chain.
func _get_registration_target(node: Node) -> Node:
  var target := node;
  if target is ComponentCombiner:
    target = target.get_component_owner();
  return target;
