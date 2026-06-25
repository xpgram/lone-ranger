@tool
extends Node2D


## The free texture, used when the hookshot is free-flying.
@export var free_texture: Texture2D;

## The lodged texture, used when the hookshot is hitched onto something.
@export var lodged_texture: Texture2D;

## The chain head sprite.
@export var sprite: Sprite2D;


func _ready() -> void:
  set_lodged(false);


## Sets the chain head's texture depending on whether it is lodged into something.
func set_lodged(value: bool) -> void:
  if value:
    sprite.texture = lodged_texture;
    sprite.offset.x = 1;
  else:
    sprite.texture = free_texture;
    sprite.offset.x = 0;
