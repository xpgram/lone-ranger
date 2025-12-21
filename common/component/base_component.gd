## @tool [br]
##
## Base component class that manages parent-owner registration. [br]
##
## Components assign themselves to a metadata key on their parent node, using their class
## name as the key. For this reason, extending component classes [b]must override the
## class_name[/b] unless it is intended to be a variant of the same component type. [br]
##
## To retrieve a component from another node:
##
## [codeblock]
## if Component.has_component(node, BaseComponent):
##     var component := Component.get_component(node, BaseComponent) as BaseComponent;
## [/codeblock]
@tool
@abstract class_name BaseComponent
extends Node


## Emitted when this component's owner is altered.
signal component_owner_changed();


@export_group('Owner')

## A reference to a remote composite node for this component. This overrides the default
## composite node, which would be this node's direct parent.
@export var _remote_component_owner: Node:
  set(value):
    _remote_component_owner = value;
    _update_ownership();


## The current composite node that owns this component.
var _component_owner: Node;


func _enter_tree() -> void:
  if not _remote_component_owner:
    _update_ownership();


func _exit_tree() -> void:
  _deregister_self(_component_owner);


## Returns the [Node] this object is a component to. [br]
##
## Will return null if this node is the scene root while [member _remote_component_owner] is not
## set.
func get_component_owner() -> Node:
  return _component_owner;


## Registers this component with the appropriate owner after a change in configuration,
## and deregisters it from its previous owner.
func _update_ownership() -> void:
  _deregister_self(_component_owner);

  _component_owner = _remote_component_owner if _remote_component_owner else get_parent();
  _register_self(_component_owner);


## Registers this component to [param node].
func _register_self(node: Node) -> void:
  Component.set_component(node, self);
  component_owner_changed.emit();


## Removes this component from [param node]'s registry.
func _deregister_self(node: Node) -> void:
  Component.remove_component(node, self);
