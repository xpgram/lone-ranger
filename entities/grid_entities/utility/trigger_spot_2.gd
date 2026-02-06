class_name TriggerSpot_2
extends GridEntity


## Emitted when a [GridEntity] collides with this one.
signal entered(entity: GridEntity);

## Emitted when a [GridEntity] separates, or stops colliding with this one.
signal exited(entity: GridEntity);


func _bind_stimulus_callbacks() -> void:
  super._bind_stimulus_callbacks();
  _stimulus_event_map.add_events({
    Stimulus.entity_collision: _on_collision,
    Stimulus.entity_separation: _on_separation,
  });


func _on_collision() -> void:
  var player := ActionUtils.get_player_entity();

  if not player.grid_position == grid_position:
    return;

  # FIXME Missing the entity argument.
  entered.emit(player);


func _on_separation() -> void:
  var player := ActionUtils.get_player_entity();

  if player.grid_position == grid_position:
    return;

  # FIXME Missing the entity argument.
  exited.emit(player);
