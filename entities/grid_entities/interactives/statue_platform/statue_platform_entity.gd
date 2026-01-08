extends Interactive2D


func _on_free_fall() -> void:
  await super._on_free_fall();
  Grid.set_tile_type(grid_position, 2);
