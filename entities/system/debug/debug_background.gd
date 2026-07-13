@tool
extends ColorRect


func _draw() -> void:
  if not Engine.is_editor_hint():
    return;

  draw_rect(
    Rect2(Vector2.ZERO, size),
    Color.GRAY,
    false,
    0.5,
  )
