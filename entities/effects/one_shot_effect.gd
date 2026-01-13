class_name OneShotEffect
extends AnimatedSprite2D


func _ready() -> void:
  animation_finished.connect(_on_animation_finished);


func set_direction(_direction: Vector2i) -> void:
  pass;


func _on_animation_finished() -> void:
  queue_free();
