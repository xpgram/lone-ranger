extends ContextAction


const _scene_save_audio := preload('uid://b7nqq1bsbqwx5');


@export var save_idol: GridEntity;


func can_interact(actor: GridEntity) -> bool:
  var initiated_from_below := (save_idol.grid_position + Vector2i.DOWN == actor.grid_position);
  var actor_facing_self := (actor.faced_direction == Vector2i.UP);

  return initiated_from_below and actor_facing_self;


func perform_interaction_async(actor: GridEntity) -> void:
  if actor is not Player2D:
    return;

  AudioBus.play_audio_scene(_scene_save_audio);

  # FIXME I need some way of making the screen shader more accessible.
  #  Uhh... I guess that's kinda what events are for? Hm.
  var whiteout_phase_time := 0.333;
  var whiteout_tween := get_tree().create_tween();
  whiteout_tween.tween_method(actor._shader_rect.set_silhoette_white_threshhold, 1.0, 0.4, whiteout_phase_time);
  whiteout_tween.tween_interval(whiteout_phase_time);
  whiteout_tween.tween_method(actor._shader_rect.set_silhoette_white_threshhold, 0.4, 1.0, whiteout_phase_time);
  whiteout_tween.play();

  var health := Component.getc(actor, HealthComponent) as HealthComponent;
  health.set_hp_to_full();

  # FIXME scuffed private variable access :p
  actor._starting_position = save_idol.grid_position + Vector2i.DOWN;

  await whiteout_tween.finished;
