## An abstract class describing the interface for an action in the game field.
## This includes anything an actor, the player, an enemy, might *do* in the game.
##
## These objects are async by nature to account for animations and other effects.
@abstract
class_name FieldAction
extends Resource


## If true, then fill_parameters() has been called.
var _parameters_filled := false;

## The actor "casting" this action.
var _performer: GridEntity;

## The Grid position this Action is being "cast" on. Serves as an origin point for other
## calculations.
var _target_position: Vector2i;

## The cardinal direction, or rotation, of this Action. Sometimes this is used for
## determining the user's final facing_direction, and sometimes it determines the rotation
## of an Area of Effect map.
var _orientation: Vector2i;


## Returns the name for this action.
@abstract func action_name() -> String;


## Returns a description of this action's effects.
@abstract func action_description() -> String;


## Returns the Partial Time cost for this action.
@abstract func action_time_cost() -> float;


## Fills parameters with data used by other functions of this object.
## This method allows the FieldAction's parameters to be pre-packaged before it is sent to
## other controllers which may not have the necessary information.
##
## Returns self for easy chaining.
func fill_parameters(
  performer: GridEntity,
  target_position: Vector2i,
  orientation: Vector2i,
) -> FieldAction:
  _performer = performer;
  _target_position = target_position;
  _orientation = orientation;
  _parameters_filled = true;

  return self;


## Given a performing actor and a cast-to position, returns True if this action can be
## successfully performed. Useful for doing preflight checks that may end up diverting
## input into other actions, such as how a Move input can also trigger a Spin or a Push.
func can_perform() -> bool:
  assert(_parameters_filled, "FieldAction '%s': Parameters have not been filled." % action_name());
  return _can_perform();


## Inheritor's implementation of `can_perform()`.
##
## Given a performing actor and a cast-to position, returns True if this action can be
## successfully performed. Useful for doing preflight checks that may end up diverting
## input into other actions, such as how a Move input can also trigger a Spin or a Push.
@abstract func _can_perform() -> bool;


## Given a performing actor and a cast-to position, coordinate the animation and ratify
## the effects of this action.
func perform_async() -> void:
  assert(_parameters_filled, "FieldAction '%s': Parameters have not been filled." % action_name());

  @warning_ignore('redundant_await')
  await _perform_async();


## Inheritor's implementation of `perform_async()`.
##
## Given a performing actor and a cast-to position, coordinate the animation and ratify
## the effects of this action.
@abstract func _perform_async() -> void;
