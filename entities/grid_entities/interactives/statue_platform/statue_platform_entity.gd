extends Interactive2D


func _on_free_fall() -> void:
  await get_tree().create_timer(0.5).timeout;
  Grid.set_tile_type(grid_position, 2);
