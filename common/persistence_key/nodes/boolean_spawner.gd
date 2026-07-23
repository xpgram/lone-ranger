## @tool [br]
##
## A container node to capture branches of the scene and spawn or respawn them as
## needed. [br]
##
## This spawner has three source scene branches: [member _false_container] and
## [member _true_container], which are used according to the boolean value of
## the persistence key with name [member _persistence_key], and
## [member _default_container], which is always spawned. [br]
##
## Spawning happens when this object is loaded, and again when
## [signal Events.board_reset_declared] is emitted. [br]
##
## Objects to be spawned must be children of one of the container nodes.
@tool
class_name BooleanSpawner
extends Node2D


## The `bool` persistence key whose value determines which scene is spawned by
## this spawner. [br]
##
## If the Resource is left empty, it is interpreted as `false`.
@export var _persistence_key: PersistenceKeyBool;

## @nullable [br]
## The source container to use for always-added objects. [br]
##
## When the game is run, this node is removed from the node_tree and duplicated
## every time the spawner is invoked.
@export var _default_container: Node;

## @nullable [br]
## The source container to use when the persistence key is 'false'. [br]
##
## When the game is run, this node is removed from the node_tree and duplicated
## according to the persistence key value. [br]
@export var _false_container: Node;

## @nullable [br]
## The source container to spawn if the persistence key is 'true'. [br]
##
## When the game is run, this node is removed from the node_tree and duplicated
## according to the persistence key value.
@export var _true_container: Node;

## The default scene used during gameplay.
var _default_instance: Node;

## The active scene used during gameplay.
var _active_instance: Node;


func _ready() -> void:
  _bind_editor_events();

  if not Engine.is_editor_hint():
    _freeze_node_branch(_default_container);
    _freeze_node_branch(_false_container);
    _freeze_node_branch(_true_container);
    _respawn_objects();
    _bind_global_events();

  queue_redraw();


func _draw() -> void:
  if not Engine.is_editor_hint():
    return;

  draw_circle(
    Vector2.ZERO,
    3.0,
    Color(0, 0.75, 0, 1),
    true
  );


## Binds handlers to event signals recognized while in-editor.
func _bind_editor_events() -> void:
  pass


## Binds handlers to global event signals.
func _bind_global_events() -> void:
  # [FIXME] This script is in ./common but depends on a game-specific library: Events.
  Events.board_reset_declared.connect(_respawn_objects);


## Disables and removes from the SceneTree the given [param node].
func _freeze_node_branch(node: Node) -> void:
  if not node:
    return;

  remove_child(node);


## Enables and prepares for use the given [param node] before adding it to the
## [SceneTree].
func _unfreeze_node_branch(node: Node) -> void:
  if not node:
    return;

  node.visible = true;
  add_child(node);


## Delete the active scene and repopulate it with a new copy of the source scene.
func _respawn_objects() -> void:
  _delete_active_scene();
  _spawn_active_scene.call_deferred();


## Queue free's all active container children.
func _delete_active_scene() -> void:
  if _default_instance:
    _default_instance.queue_free();
  if _active_instance:
    _active_instance.queue_free();


## Populates the active scene with a new copy of the source scene. If the
## determined source scene is null, then does nothing.
func _spawn_active_scene() -> void:
  var source_scene := _get_source_scene();

  if _default_container:
    _default_instance = _default_container.duplicate();
    _unfreeze_node_branch(_default_instance);

  if source_scene:
    _active_instance = source_scene.duplicate();
    _unfreeze_node_branch(_active_instance);


## @nullable
##
## Returns the current source scene, the one to populate the active scene with.
## Will return null if the current source scene is null.
func _get_source_scene() -> Node:
  return (
    _true_container if _persistence_key and _persistence_key.read()
    else _false_container
  );
