class_name TriggerSpot_2
extends GridEntity


signal triggered(entity: GridEntity);


func _bind_stimulus_callbacks() -> void:
  super._bind_stimulus_callbacks();
  _stimulus_event_map.add_events({
    Stimulus.entity_collision: _on_collision,
  });


func _on_collision() -> void:
  var player := ActionUtils.get_player_entity();

  if not player.grid_position == grid_position:
    return;

  # FIXME Missing the entity argument.
  triggered.emit();
