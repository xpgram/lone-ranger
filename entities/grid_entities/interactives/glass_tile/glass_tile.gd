extends GridEntity


const _scene_glass_crack_audio := preload('uid://cgpaem3pcvr4u');
const _scene_glass_break_effect := preload('uid://da6wyd1fs28c2');


func _bind_stimulus_callbacks() -> void:
  super._bind_stimulus_callbacks();

  _stimulus_event_map.add_events({
    Stimulus.entity_collision: _on_entity_collision,
    Stimulus.entity_separation: _on_entity_separated,
  });


func _on_entity_collision() -> void:
  # TODO if entity.solid:
  AudioBus.play_audio_scene(_scene_glass_crack_audio);


func _on_entity_separated() -> void:
  # TODO if leaving_entity.solid:
  if not ActionUtils.place_is_obstructed(grid_position):
    _break_glass();


func _break_glass() -> void:
  var glass_break := _scene_glass_break_effect.instantiate();
  add_sibling(glass_break);

  glass_break.global_position = Grid.get_world_coords(grid_position);

  queue_free();
