@tool
## @tool [br]
##
## A container node to capture a branch of the scene and spawn or respawn it as needed.
##
## Objects to be spawned must be children of the [member _source_container] node.
## This tool script will create this node for you, if it does not exist, when this
## node is first '_ready'.
class_name SceneSpawner
extends Node2D


@export var _source_container: Node2D;

var _active_container: Node2D;


func _ready() -> void:
  # _ensure_source_scene_exists();
  _bind_editor_events();

  if not Engine.is_editor_hint():
    _freeze_container(_source_container);
    _respawn_objects();
    _bind_global_events();


func _draw() -> void:
  if Engine.is_editor_hint():
    return;

  draw_circle(
    position,
    0.5,
    Color.GREEN,
    true,
  );


## Binds handlers to event signals recognized while in-editor.
func _bind_editor_events() -> void:
  pass


## Binds handlers to global event signals.
func _bind_global_events() -> void:
  Events.board_reset_declared.connect(_respawn_objects);


## If the source container node does not exist, creates one.
func _ensure_source_scene_exists() -> void:
  if not _source_container:
    _source_container = Node2D.new();
    _source_container.name = "SourceScene";
    add_child(_source_container);


## Hide and stop processing the given [param container] Node.
func _freeze_container(container: Node) -> void:
  container.visible = false;
  container.process_mode = Node.PROCESS_MODE_DISABLED;


## Show and start processing the given [param container] Node.
func _unfreeze_container(container: Node) -> void:
  container.visible = true;
  container.process_mode = Node.PROCESS_MODE_PAUSABLE;


## Delete the active scene and repopulate it with a new copy of the source scene.
func _respawn_objects() -> void:
  _delete_active_scene();
  _spawn_active_scene();


## Queue free's all active container children.
func _delete_active_scene() -> void:
  if _active_container:
    _active_container.queue_free();


## Populates the active scene with a new copy of the source scene.
func _spawn_active_scene() -> void:
  _active_container = _source_container.duplicate();
  _active_container.name = "ActiveScene";
  add_child(_active_container);
  _unfreeze_container(_active_container);
