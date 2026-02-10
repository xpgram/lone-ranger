class_name PickupInteractive2D
extends Interactive2D


# FIXME I did this work really fast, and in retrospect, it's a bit overkill.
#  Collisions are common enough to go in GridEntity itself.
func _bind_stimulus_callbacks() -> void:
  super._bind_stimulus_callbacks();
  _stimulus_event_map.add_events({
    Stimulus.object_collision: _on_collide,
  });


func _on_collide(_entity: GridEntity) -> void:
  # TODO entity: GridEntity is passed in as an argument.
  pass
