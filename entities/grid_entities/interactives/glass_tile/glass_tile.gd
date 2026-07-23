extends GridEntity


const _scene_glass_crack_audio := preload('uid://cgpaem3pcvr4u');
const _scene_glass_break_effect := preload('uid://da6wyd1fs28c2');


## Whether the glass spawns in cracked. Skips the SFX when loading in.
@export var _pre_cracked := false;


func _bind_stimulus_callbacks() -> void:
  super._bind_stimulus_callbacks();

  _stimulus_event_map.add_events({
    Stimulus.object_collision: _on_entity_collision,
    Stimulus.object_separation: _on_entity_separated,
  });


func _on_entity_collision(entity: GridEntity) -> void:
  if not entity.solid or _pre_cracked:
    return;
  AudioBus.play_audio_scene(_scene_glass_crack_audio);


func _on_entity_separated(entity: GridEntity) -> void:
  if (
      entity.solid
      and not ActionUtils.place_is_obstructed(grid_position)
  ):
    _break_glass();


func _break_glass() -> void:
  # [FIXME] This shouldn't be called when a BooleanSpawner 'freezes' a branch.
  #   Or said another way, this shouldn't be called when this glass tile is, or
  #   is about to be, queue_free()'d. At least I think?
  #
  #   The problem:
  #   When the node branch is being destroyed, the boulder 'leaves' the Grid,
  #   causing a separation collision. Glass tile tries to break itself
  #   accordingly, fails, and then is queue_freed itself moments later.
  #
  #   Um. It's possible this isn't a problem, per se, but it does cause annoying
  #   errors, and it _might_ represent a structural issue in the sense that
  #   unnecessary work is being done.
  var glass_break := _scene_glass_break_effect.instantiate();
  add_sibling(glass_break);

  glass_break.global_position = Grid.get_world_coords(grid_position);

  queue_free();
