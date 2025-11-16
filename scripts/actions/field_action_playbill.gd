## A struct describing the actors in a Field Action.
class_name FieldActionPlaybill
extends RefCounted


## The actor to perform an action. Used for stats polling, positioning, movement, etc.
var performer: GridEntity;

## The Grid position the Action is being "cast" to. Serves as an origin point for Area of
## Effect maps and other calculations.
var target_position: Vector2i;

## The cardinal direction, or rotation, of this Action.
## Sometimes this is used to determine the performer's final face direction, and
## sometimes it's used to determine the rotation of an Area of Effect map.
var orientation: Vector2i;


@warning_ignore('shadowed_variable')
func _init(
  performer: GridEntity,
  target_position: Vector2i,
  orientation: Vector2i,
) -> void:
  self.performer = performer;
  self.target_position = target_position;
  self.orientation = orientation;
