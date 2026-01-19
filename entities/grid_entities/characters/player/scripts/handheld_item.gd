class_name PlayerHandheldItem
extends Node2D


enum HandheldItemType {
  Scepter,
  Sword,
};

## A dictionary of handheld item textures.
@export var item_textures: Dictionary[HandheldItemType, Texture2D];

## Reference to the handheld item sprite.
@export var handheld_sprite: Sprite2D;


## Sets the handheld item to the predefined texture associated with [param item_type].
func set_item(item_type: HandheldItemType) -> void:
  var texture: Texture2D = item_textures.get(item_type);

  if texture:
    handheld_sprite.texture = texture;
  else:
    push_error('Could not set handheld texture: enum %s has no value.' % item_type);
