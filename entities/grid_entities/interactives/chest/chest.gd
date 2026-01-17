@tool
class_name ChestEntity
extends Interactive2D

## The contents of this chest.
@export var contents: Array[PlayerInventoryItem];

## Whether this Chest has been opened.
@export var is_open := false:
  set(value):
    is_open = value;

    if is_open:
      animated_sprite.play('open');
    else:
      animated_sprite.play('closed');

@onready var animated_sprite := %AnimatedSprite2D;
