class_name TriggerSpot
extends GridEntity


@export var activateable_entity: GridEntity;


func _bind_stimulus_callbacks() -> void:
  super._bind_stimulus_callbacks();
  _stimulus_event_map.add_events({
    Stimulus.object_collision: _on_collision,
  });


func _on_collision(_entity: GridEntity) -> void:
  var player := ActionUtils.get_player_entity();

  if not player.grid_position == grid_position:
    return;

  # FIXME This doesn't even check it has this property.
  #  I should probably do this with an on_trigger() component. That would be generic enough.
  var actor_component := Component.getc(activateable_entity, GridActorComponent) as GridActorComponent;
  actor_component.activated = true;
