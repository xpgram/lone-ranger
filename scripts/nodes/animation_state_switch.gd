class_name AnimationStateSwitch
extends Node


@export var animation_player: AnimationPlayer;

@export var states: Dictionary[String, StringCrossSwitch];


func play(state_key: StringName, direction: Vector2i) -> void:
  if not states.has(state_key):
    return;

  var switch := states[state_key];
  var animation_key := switch.get_value(direction);

  if not animation_player.has_animation(animation_key):
    return;

  animation_player.play('RESET');
  animation_player.advance(0);

  animation_player.play(animation_key);
  animation_player.advance(0);
