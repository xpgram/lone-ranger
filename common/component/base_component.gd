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

## A reference to a remote compositor node for this component. This overrides the default
## compositor node, which would be this node's direct parent. [br]
##
## "Compositor" here means this node may be the component owner, or it may be a proxy-type
## object to the component owner. (See [ComponentCombiner].)
@export var _remote_component_owner: Node:
  set(value):
    _remote_component_owner = value;
    _update_ownership();


## The node that is directly responsible for this component. This may be the component
## owner, or it may be a proxy to the component owner.
var _compositor_node: Node;


func _enter_tree() -> void:
  if not _remote_component_owner:
    _update_ownership();


func _exit_tree() -> void:
  _deregister_self(_compositor_node);


## Returns the [Node] this object is a component to. [br]
##
## Will return null if this node is the scene root while [member _remote_component_owner]
## is not set.
func get_component_owner() -> Node:
  return _get_registration_target(_compositor_node);


## Registers this component with the appropriate owner after a change in configuration,
## and deregisters it from its previous owner.
func _update_ownership() -> void:
  _deregister_self(_compositor_node);
  _compositor_node = _remote_component_owner if _remote_component_owner else get_parent();
  _register_self(_compositor_node);


## Returns either the [param node] given, or if [param node] is a special component proxy
## type, returns the registration target at the end of the [code]owner->owner->owner[/code]
## chain.
func _get_registration_target(node: Node) -> Node:
  var target := node;
  if target is ComponentCombiner:
    target = target.get_component_owner();
  return target;


## Registers this component to [param node]. [br]
## If [param node] is a [ComponentCombiner], then it will be registered to the combiner's
## component owner.
func _register_self(node: Node) -> void:
  _try_connect_proxy_listener(node);
  var registration_target := _get_registration_target(node);
  Component.set_component(registration_target, self);
  component_owner_changed.emit();


## Removes this component from [param node]'s registry. [br]
## If [param node] is a [ComponentCombiner], then it will be removed from the combiner's
## component owner.
func _deregister_self(node: Node) -> void:
  _try_disconnect_proxy_listener(node);
  var registration_target := _get_registration_target(node);
  Component.remove_component(registration_target, self);


## If [param node] is a component proxy type object, connects to signals emitted by the
## proxy.
func _try_connect_proxy_listener(node: Node) -> void:
  if node is ComponentCombiner:
    node.component_owner_changed.connect(_update_ownership);


## If [param node] is a component proxy type object, disconnects from signals emitted by
## the proxy.
func _try_disconnect_proxy_listener(node: Node) -> void:
  if node is ComponentCombiner:
    if node.component_owner_changed.is_connected(_update_ownership):
      node.component_owner_changed.disconnect(_update_ownership);
