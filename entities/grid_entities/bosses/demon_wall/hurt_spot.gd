extends GridEntity



func _ready() -> void:
  super._ready();
  grid_position_changed.connect(_on_entity_moved);


func _on_entity_moved(_to: Vector2i, _from: Vector2i) -> void:
  pass
  # var entities := Grid.get_entities(grid_position);

  # for entity in entities:
  #   if entity is Player2D:
  #     _attack_async(entity);


func _on_free_fall() -> void:
  pass;
