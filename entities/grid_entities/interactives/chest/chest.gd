@tool
class_name ChestEntity
extends Interactive2D

# TODO These content fields should probably be consolidated.

## The contents of this chest.
@export var contents: Array[PlayerInventoryItem];

## The equipment-type contents of this chest.
@export var equipment_contents: Array[StringName];

## Whether this Chest has been opened.
@export var is_open := false:
  set(value):
    is_open = value;

    if is_open:
      animated_sprite.play('open');
    else:
      animated_sprite.play('closed');

@onready var animated_sprite := %AnimatedSprite2D;
