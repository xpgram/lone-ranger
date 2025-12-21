## The properties and metrics data for a Grid entity attribute.
## Attributes are used to describe applied effects, even temporary effects, like passive
## qualities, equipment side effects, status effects, and more.
class_name GridEntityAttribute
extends Resource


## Used when saving tres files and instantiating them.
## This key is the name of this attribute and what it should be stored under when applied
## to an attribute dictionary.
@export var attribute_key: StringName;


@export_subgroup('Remedies')

## Whether this effect can dissipate on its own.
@export var self_remedying := true;

## How many turns until this effect dissipates.
## Has no effect if `self_remedying` is `false`.
@export var turn_duration := 1;


## How long this attribute has been active for.
@export_storage var _turn_count := 0;
## How long this attribute has been active for.
var turn_count: int: get = _get_turn_count;

## How many applications of this attribute have been applied simultaneously.
@export_storage var _stack_count := 1;
## How many applications of this attribute have been applied simultaneously.
var stack_count: int: get = _get_stack_count;


var _exhausted := false;


## Marks this effect as nullified and ready to be removed.
func nullify() -> void:
  _exhausted = true;


## Returns true if this attribute is nullified and ready to be removed.
func is_nullified() -> bool:
  return _exhausted;


## Merges this attribute with `param data`, preferring the properties of whichever one
## represents a higher potency.
func merge(other: GridEntityAttribute) -> GridEntityAttribute:
  var merged := duplicate();
  
  merged._stack_count += 1;
  merged.turn_duration = maxi(merged.turn_duration, other.turn_duration);

  return merged;


## Updates this attribute's metrics.
## Should be called once per turn.
func update() -> void:
  _increment_turn_count();


## Increments the turn counter for this attribute and nullifies it if it meets any self-
## remedying requirements.
func _increment_turn_count() -> void:
  _turn_count += 1;

  # The turn count must *surpass* turn duration so that a turn duration of 1 is accurately
  # counted as one full turn, while 0 may be discarded immediately.
  if self_remedying and _turn_count >= turn_duration:
    nullify();


## Returns the number of turns that have passed since this attribute was applied.
func _get_turn_count() -> int:
  return _turn_count;


## Returns the number of this attribute that have been simultaneously applied.
func _get_stack_count() -> int:
  return _stack_count;
