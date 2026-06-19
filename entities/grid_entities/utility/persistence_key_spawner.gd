@tool
## @tool [br]
##
## A container node to capture branches of the scene and spawn or respawn them as
## needed.
##
## This spawner has two source scene branches, [member _false_container] and
## [member _true_container], which are used according to the boolean value of
## the persistence key with name [member _persistence_key].
##
## Spawning happens when this object is loaded, and again when
## [signal Events.board_reset_declared] is emitted.
##
## Objects to be spawned must be children of one of the container nodes.
## This tool script will create these for you, if they do not exist, when this
## node is first '_ready'.
class_name PersistenceKeySpawner
extends Node2D


## The persistence key whose value determines which scene is spawned by
## this spawner.
@export var _persistence_key: String;

## The source container to use when the persistence key is 'false'.
##
## When the game is run, this node is converted to a [PackedScene] and unloaded.
@export var _false_container: Node2D;

## The source container to spawn if the persistence key is 'true'.
##
## When the game is run, this node is converted to a [PackedScene] and unloaded.
@export var _true_container: Node2D;

## @nullable [br]
## The PackedScene to instantiate if the persistence key is 'false'.
var _false_scene: PackedScene;

## @nullable [br]
## The PackedScene to instantiate if the persistence key is 'true'.
var _true_scene: PackedScene;

## The active scene used during gameplay.
var _active_container: Node2D;


func _ready() -> void:
  _bind_editor_events();

  if not Engine.is_editor_hint():
    _false_scene = _pack_scene_and_unload(_false_container);
    _true_scene = _pack_scene_and_unload(_true_container);
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


## @nullable
##
## Converts the given [param node] into a [PackedScene], then queue frees the
## node. Returns the created [PackedScene], or null if [param node] wasn't given.
func _pack_scene_and_unload(node: Node) -> PackedScene:
  if not node:
    return null;

  var node_path := node.get_path();
  remove_child(node);

  var scene := PackedScene.new();
  var result := scene.pack(node);

  assert(result == OK,
    "Error code %s given while packing the given scene: %s" % [result, node_path]);

  node.queue_free();
  return scene;


## If the child [param node] does not exist, creates one and returns it.
func _ensure_node_exists(node: Node2D, node_name: String) -> Node2D:
  # [FIXME] This doesn't add to scene in the editor properly.
  if node:
    return node;

  var new_node = Node2D.new();
  new_node.name = node_name;
  add_child(new_node);

  return new_node;


## Delete the active scene and repopulate it with a new copy of the source scene.
func _respawn_objects() -> void:
  _delete_active_scene();
  _spawn_active_scene();


## Queue free's all active container children.
func _delete_active_scene() -> void:
  if _active_container:
    _active_container.queue_free();


## Populates the active scene with a new copy of the source scene. If the
## determined source scene is null, then does nothing.
func _spawn_active_scene() -> void:
  var source_scene := _get_source_scene();

  if not source_scene:
    return;

  _active_container = source_scene.instantiate();
  add_child(_active_container);


## @nullable
##
## Returns the current source scene, the one to populate the active scene with.
## Will return null if the current source scene is null.
func _get_source_scene() -> PackedScene:
  if PersistenceKey.get_bool(_persistence_key):
    return _true_scene;
  else:
    return _false_scene;
