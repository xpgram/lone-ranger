class_name AnimationSetPlayer
extends Node

# TODO Refactor this to take an array of AnimationStates (or whatever name), which is
#   an abstract Resource inherited by DirectionAnimationState and SingleAnimationState (or
#   something).
#
#   These would be used via the inspector like this:
#   DirectionAnimationState:
#     name:  'idle'
#     up:    'idle_up'
#     down:  'idle_down'
#     left:  'idle_left'
#     right: 'idle_right'
#   SingleAnimationState:
#     name: 'celebrate'
#     state: 'item_get!'
#
#   And would be used in code like this:
#   `state_controllers[0].get_state(facing_direction)`
#   Or maybe:
#   `if state_controller[0] is DirectionAnimationState: return ''.get_state(facing_direction)`


const STATES := {
  &'idle': [&'idle_up', &'idle_down', &'idle_left', &'idle_right'],
  &'push': [&'push_up', &'push_down', &'push_left', &'push_right'],
  &'item_use': [&'item_use_up', &'item_use_down', &'item_use_left', &'item_use_right'],
  &'item_get!': [&'item_get!'],
  &'injured': [&'injured'],
};

# TODO Export instead.
@onready var animation_player: AnimationPlayer = %AnimationPlayer;


func play(state: StringName, direction: Vector2i) -> void:
  var animation_set: Array[String];
  animation_set.assign(STATES[state]);
  var new_animation_state: String;

  if animation_set.size() == 1:
    new_animation_state = animation_set[0];
  elif animation_set.size() == 4:
    new_animation_state = _get_4way_state(animation_set, direction);

  animation_player.play(new_animation_state);


func _get_4way_state(animation_set: Array[String], direction: Vector2i) -> StringName:
  var state: StringName;

  match direction:
    Vector2i.UP:
      state = animation_set[0];
    Vector2i.DOWN:
      state = animation_set[1];
    Vector2i.LEFT:
      state = animation_set[2];
    Vector2i.RIGHT:
      state = animation_set[3];

  return state;
