extends AnimatedSprite2D


func _ready() -> void:
  animation_finished.connect(_on_animation_finished);


func set_direction(direction: Vector2i) -> void:
  match direction:
    Vector2i.LEFT:
      flip_h = true;
    Vector2i.RIGHT:
      flip_h = false;


func _on_animation_finished() -> void:
  queue_free();
