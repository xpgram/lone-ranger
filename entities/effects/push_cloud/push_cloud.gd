extends OneShotEffect


func set_direction(direction: Vector2i) -> void:
  match direction:
    Vector2i.UP:
      play('push_up');
      flip_v = false;

    Vector2i.DOWN:
      play('push_up');
      flip_v = true;

    Vector2i.LEFT:
      play('push_right');
      flip_h = true;

    Vector2i.RIGHT:
      play('push_right');
      flip_h = false;
