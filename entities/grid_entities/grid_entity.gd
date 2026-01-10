## An object which maintains a position on the Grid.
class_name GridEntity
extends Node2D


## Emitted when this entity changes its position on the Grid.
signal entity_moved();


# TODO As I add more conditions here, I should consider extracting them to a Resource.
#   Having to go through every monster and object I've ever created just to check
#   'pushable' is irritating.

## Whether this entity obstructs the travel of other entities, like walls do.
@export var solid := false;

## Whether this entity can be forcibly moved into another Grid position.
@export var pushable := false;

# TODO observes_golem_time only makes sense to GridActorComponents, so should be located there?
## Whether this entity adheres to the more turn-based golem time instead of the ongoing
## action timer.
@export var observes_golem_time := false;

# TODO This attribute-tag system should be a component node, actually.
## A dictionary of applied effects and qualities.
@export var _attributes: Dictionary[StringName, GridEntityAttribute];


## The map of stimulus events to entity reaction behaviors.
var _stimulus_event_map := InternalEventMap.new();


## The orientation of this entity, or which cardinal direction it is looking in.
var faced_direction := Vector2i.DOWN:
  get():
    return faced_direction;
  set(dir):
    faced_direction = dir;
    _facing_changed();

## The Grid coordinate position this entity is facing.
var faced_position: Vector2i:
  get():
    return grid_position + faced_direction;

## This object's position on the Grid.
## When setting this value, this object's Grid position is automatically updated.
var grid_position: Vector2i:
  get():
    return Grid.get_grid_coords(global_position);
  set(grid_vector):
    Grid.remove(self, grid_position);
    global_position = Grid.get_world_coords(grid_vector);
    Grid.put(self, grid_position);
    entity_moved.emit();

    if ActionUtils.place_is_pit(grid_position):
      react_async(Stimulus.is_over_pit);


func _enter_tree() -> void:
  Grid.put(self, grid_position);


func _exit_tree() -> void:
  Grid.remove(self, grid_position);


func _ready() -> void:
  if Engine.is_editor_hint():
    return;

  _bind_stimulus_callbacks();


## Returns true if `param attribute_name` is among the _attributes applied to this entity.
func has_attribute(attribute_name: StringName) -> bool:
  return _attributes.has(attribute_name);


## Returns the Attribute object for an attribute applied to this entity.
func get_attribute(attribute_name: StringName) -> GridEntityAttribute:
  # This may be refactor to .get(key, default) if I can think of what a useful default
  # might be.
  return _attributes[attribute_name];


## Applies an attribute to this entity. If this attribute was already applied, then the
## given attribute will merge with the existing one.
func apply_attribute(attribute_name: StringName, data: GridEntityAttribute) -> void:
  if _attributes.has(attribute_name):
    _attributes[attribute_name] = _attributes[attribute_name].merge(data);
  else:
    _attributes[attribute_name] = data;


## Iterates over the entity's collection of _attributes, updating their metrics, and
## removing them if their nullified.
func update_attributes() -> void:
  for attribute_key in _attributes:
    var attribute := _attributes[attribute_key];

    attribute.update();

    if attribute.is_nullified():
      _attributes.erase(attribute_key);


## Notifies the [GridEntity] that [param stimulus_name] has occurred and executes its
## associated behavior, if any is defined.
func react_async(stimulus_name: StringName) -> void:
  await _stimulus_event_map.call_event_async(stimulus_name);


## Returns the Grid distance between this entity and [param other]. [br]
##
## [param other] is a [GridEntity] or a [Vector2i].
func distance_to(other: Variant) -> int:
  var other_pos: Vector2i = other.grid_position if other is GridEntity else other;
  var distance_vector := (grid_position - other_pos).abs();
  return distance_vector.x + distance_vector.y;


## Overridable function called whenever this GridEntity's facing direction is changed.
## Useful for updating sprite animations.
func _facing_changed() -> void:
  pass


## Binds methods to event signals in the GridEntity stimulus reaction system. [br]
##
## If overriding, remember to call super().
func _bind_stimulus_callbacks() -> void:
  _stimulus_event_map.add_events({
    Stimulus.is_over_pit: _on_free_fall,
  });


## Overridable function called whenever the Grid cell at this GridEntity's location is
## missing a floor to stand on. [br]
##
## By default, this function waits a small amount of time and then queues self for
## deletion.
func _on_free_fall() -> void:
  # TODO Create a drop effect animation.
  await get_tree().create_timer(0.5).timeout;
  queue_free();


## @internal-only [br]
## An event-key dictionary manager to facilitate [GridEntity]'s stimulus reaction system. [br]
##
## The purpose of this is to enforce stronger parity between types that implement similar
## functions, but which may not implement them at all. It is recommended to use a
## collection of constants to manage event keys consistently. [br]
##
## Usage example:
## [codeblock]
## class_name Enemy2D extends GridEntity
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
      assert(not _events.has(key), "Cannot overwrite GridEntity event key '%s'.");

    _events.merge(event_map);


  ## If [param event_name] exists in the event map, calls its associated function.
  func call_event(event_name: StringName) -> void:
    call_event_async(event_name);


  ## If [param event_name] exists in the event map, calls and awaits its associated
  ## function.
  func call_event_async(event_name: StringName) -> void:
    if _events.has(event_name):
      await _events.get(event_name).call();