extends AnimationPlayer


var animations := get_animation_library_list();


## Resets the animation state using the values defined in the RESET animation.
func reset() -> void:
  play('RESET');
  advance(0);


## Resets the animation state, then plays the animation with key `param animation_name`.
func reset_play(animation_name: StringName) -> void:
  assert(has_animation(animation_name),
    "AnimationPlayer '%s' has no animation key '%s'." % [name, animation_name]);

  reset();
  play(animation_name);
