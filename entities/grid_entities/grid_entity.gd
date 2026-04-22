## A [Grid] object representing a game entity, e.g., characters, interactive chests,
## pickups, etc.
class_name GridEntity
extends GridObject


const _scene_object_fall := preload('uid://c3dfb7ml0p2ln');


# TODO As I add more conditions here, I should consider extracting them to a Resource.
#   Having to go through every monster and object I've ever created just to check
#   'pushable' is irritating.

## Whether this entity obstructs the travel of other entities, like walls do.
@export var solid := false;

## Whether this entity can be forcibly moved into another Grid position.
@export var pushable := false;

## Whether this entity is a flooring-type that other entities can stand on.
@export var standable := false;

# TODO observes_golem_time only makes sense to GridActorComponents, so should be located there?
## Whether this entity adheres to the more turn-based golem time instead of the ongoing
## action timer.
@export var observes_golem_time := false;

# TODO This attribute-tag system should be a component node, actually.
## A dictionary of applied effects and qualities.
@export var _attributes: Dictionary[StringName, GridEntityAttribute];


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


func _ready() -> void:
  if Engine.is_editor_hint():
    return;

  super._ready();
  _bind_grid_object_signals();


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


## Binds methods to [GridObject] signals.
func _bind_grid_object_signals() -> void:
  grid_position_changed.connect(_on_grid_position_changed);


func _bind_stimulus_callbacks() -> void:
  super._bind_stimulus_callbacks();
  _stimulus_event_map.add_events({
    Stimulus.is_over_pit: _on_free_fall,
  });


## Handles [GridEntity]'s reaction to movement or new-location stimuli.
func _on_grid_position_changed(to: Vector2i, _from: Vector2i) -> void:
  if (
      ActionUtils.place_is_pit(to)
      and not ActionUtils.place_is_idleable(to, self)
  ):
    react_async(Stimulus.is_over_pit);


## Overridable function called whenever this GridEntity's facing direction is changed.
## Useful for updating sprite animations.
func _facing_changed() -> void:
  pass


## Overridable function called whenever the Grid cell at this GridEntity's location is
## missing a floor to stand on. [br]
##
## By default, this function waits a small amount of time and then queues self for
## deletion.
func _on_free_fall() -> void:
  await get_tree().create_timer(0.5).timeout;

  var fall_effect := _scene_object_fall.instantiate();
  fall_effect.position = position;
  add_sibling(fall_effect);

  queue_free();
