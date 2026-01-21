@tool
extends Node2D


## How many tiles of chain to draw extending rightward from the origin.
@export var tiled_length := 1:
  set(value):
    tiled_length = value;
    queue_redraw();

## The chain segment texture to draw. It is assumed this segment is half the width of a
## standard [Grid] cell.
@export var _texture: Texture2D;


func _draw() -> void:
  var center := Vector2(
    _texture.get_width() / 2.0,
    _texture.get_height() / 2.0,
  );
  var x_displacement := _texture.get_width();

  var half_segment_count := (
    tiled_length * 2 + 1 if tiled_length > 0
    else 0
  );

  for i in range(half_segment_count):
    draw_texture(
      _texture,
      Vector2(
        i * x_displacement - center.x,
        -center.y,
      )
    );
