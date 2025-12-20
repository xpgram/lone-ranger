## Base component class that manages parent-owner registration. [br]
##
## Components assign themselves to a metadata key on their parent node, using their class
## name as the key. For this reason, extending component classes [b]must override the
## class_name.[/b] [br]
##
## To retrieve a component from another node:
##
## [codeblock]
## if Component.has_component(node, BaseComponent):
##     var component := Component.get_component(node, BaseComponent) as BaseComponent;
## [/codeblock]
@abstract class_name BaseComponent
extends Node


@export_group('Owner')

## The node this object is a component to. By default, this is this node's direct parent.
@export var component_owner: Node:
  set(value):
    Component.remove_component(component_owner, self);

    component_owner = value;
    if component_owner:
      Component.set_component(component_owner, self);


func _ready() -> void:
  if not component_owner:
    component_owner = get_parent();


func _exit_tree() -> void:
  Component.remove_component(component_owner, self);
