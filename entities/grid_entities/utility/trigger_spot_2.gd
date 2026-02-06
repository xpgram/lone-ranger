class_name TriggerSpot_2
extends GridEntity


# TODO Swap the class names for TriggerSpot and TriggerSpot_2.
# TODO How will areas be handled? Do I really need a separate entity for each one?
#   If I'm not going to use an Area2D, then Grid will just have to notify 'something'.
#   'Something' can be a TriggerSpot, I guess, but if it didn't need 'solid' or 'pushable'
#   properties, that would be nice.
#   Or maybe... what if we allowed one GridEntity TriggerSpot to inhabit multiple places?
#   Hm...
# TODO Implement into DemonWall boss, replacing the previous triggerspot.
# TODO Can we limit the overhead from being a GridEntity? TriggerSpots don't need "solid" or "pushable".
# TODO Implement NotifyEntity, a pair to Stimulus
#   I'm... not going to refactor Stimulus yet. I still need function signatures in the doc strings.
#   NotifyEntity.bumped(entities)         [Triggers a Stimulus reaction.]
#   NotifyEntity.secret_knocked(entities) [Collects and 'taps' a BumpComponent.]


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


func _on_collision(entity: GridEntity) -> void:
  entered.emit(entity);


func _on_separation(entity: GridEntity) -> void:
  exited.emit(entity);
