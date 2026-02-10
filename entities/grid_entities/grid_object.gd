## The base class for all [Grid] objects.
class_name GridObject
extends Node2D


## Emitted when this object's location on the Grid has changed.
signal grid_position_changed(to: Vector2i, from: Vector2i);


## This object's position on the Grid. [br]
##
## Setting this value will call [member _update_grid_location] and emit
## [signal grid_position_changed].
var grid_position: Vector2i:
  get():
    return Grid.get_grid_coords(global_position);
  set(grid_vector):
    var old_grid_position := grid_position;
    global_position = Grid.get_world_coords(grid_vector);

    _update_grid_location(grid_position, old_grid_position);
    grid_position_changed.emit(grid_position, old_grid_position);


## The map of stimulus events to reaction behaviors.
var _stimulus_event_map := InternalEventMap.new();


func _enter_tree() -> void:
  Grid.put(self, grid_position);


func _exit_tree() -> void:
  Grid.remove(self, grid_position);


func _ready() -> void:
  if Engine.is_editor_hint():
    return;

  _bind_stimulus_callbacks();


## Notifies the [GridObject] that [param stimulus_name] has occurred and executes its
## associated behavior, if any is defined. [br]
##
## [param arguments] is a list of whatever arguments satisfy the function signature of the
## [Stimulus] event given.
func react_async(stimulus_name: StringName, arguments := []) -> void:
  await _stimulus_event_map.call_event_async(stimulus_name, arguments);


## Returns the Grid distance between this object and [param other]. [br]
##
## [param other] is a [GridObject] or a [Vector2i].
func distance_to(other: Variant) -> int:
  var other_pos: Vector2i = other.grid_position if other is GridObject else Vector2i(other);
  var distance_vector := (grid_position - other_pos).abs();
  return distance_vector.x + distance_vector.y;


## Moves this object's presence on the [Grid] to its new [member grid_position].
func _update_grid_location(to: Vector2i, from: Vector2i) -> void:
  Grid.remove(self, from);
  Grid.put(self, to);


## Binds methods to event signals in the [GridObject] stimulus reaction system. [br]
##
## If overriding, remember to call super(). You can add new stimulus callbacks with
## [method _stimulus_event_map.add_events].
func _bind_stimulus_callbacks() -> void:
  pass


## @internal-only [br]
## An event-key dictionary manager to facilitate [GridObject]'s stimulus reaction system. [br]
##
## The purpose of this is to enforce stronger parity between types that implement similar
## functions, but which may not implement them at all. It is recommended to use a
## collection of constants to manage event keys consistently. [br]
##
## Usage example:
## [codeblock]
## class_name Enemy2D extends GridObject
##
## func _ready() -> void:
##     stimulus_map.add_events({
##         Stimulus.is_burning: _on_burning,
##         # ...
##     });
##
## func _on_burning() -> void:
##     # ...
##
## func self_combust() -> void:
##     # ...
##     stimulus_map.call_event(Stimulus.is_burning);
## [/codeblock]
class InternalEventMap extends RefCounted:
  var _events: Dictionary[StringName, Callable];

  ## Merges [param event_map] with the collection of event callbacks. [br]
  ##
  ## This will raise an error when a key conflict is detected. Event handler overrides
  ## should be done the inheritance way, by overriding the super's function directly.
  func add_events(event_map: Dictionary[StringName, Callable]) -> void:
    for key in event_map.keys():
      assert(not _events.has(key), "Cannot overwrite GridObject event key '%s'.");

    _events.merge(event_map);


  ## If [param event_name] exists in the event map, calls and awaits its associated
  ## function. [br]
  ##
  ## All stimulus event listeners are assumed to be async by default, but this ultimately
  ## comes down to implementation.
  func call_event_async(event_name: StringName, arguments := []) -> void:
    if _events.has(event_name):
      await _events.get(event_name).callv(arguments);
