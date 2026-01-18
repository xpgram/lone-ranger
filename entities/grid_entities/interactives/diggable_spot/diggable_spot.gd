class_name DiggableSpotEntity
extends GridEntity


@export var _pickup_spawn: PackedScene;


func _on_spell_activated__raise() -> void:
  _spawn_pickup();
  queue_free();


func _spawn_pickup() -> void:
  if not _pickup_spawn:
    return;

  var pickup_entity: GridEntity = _pickup_spawn.instantiate();
  add_sibling(pickup_entity);
  pickup_entity.grid_position = grid_position;
