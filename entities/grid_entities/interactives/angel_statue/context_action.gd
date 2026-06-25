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

  var player := actor as Player2D;
  var screen_shader := player.get_screen_shader();
  var whiteout_phase_time := 0.333;

  player.replenish_all();
  player.set_revive_point(player.grid_position);

  AudioBus.play_audio_scene(_scene_save_audio);
  await screen_shader.white_out_async(whiteout_phase_time);

  Events.board_reset_declared.emit();
  
  await screen_shader.white_in_async(whiteout_phase_time, whiteout_phase_time);
