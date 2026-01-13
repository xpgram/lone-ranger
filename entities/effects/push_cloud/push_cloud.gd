extends OneShotEffect


func set_direction(direction: Vector2i) -> void:
  match direction:
    Vector2i.LEFT:
      flip_h = true;
    Vector2i.RIGHT:
      flip_h = false;
