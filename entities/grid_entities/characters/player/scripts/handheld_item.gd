class_name PlayerHandheldItem
extends Node2D


enum HandheldItemType {
  None,
  Scepter,
  Sword,
  Hookshot,
};

## A dictionary of handheld item textures.
@export var item_textures: Dictionary[HandheldItemType, Texture2D];

## A dictionary of handheld item, visual component nodes.
@export var _item_nodes: Dictionary[HandheldItemType, Node2D];

## Reference to the handheld item sprite.
@export var handheld_sprite: Sprite2D;


## Sets the handheld item to the predefined texture associated with [param item_type].
func set_item(item_type: HandheldItemType) -> void:
  if _item_nodes.has(item_type):
    _set_tool_visible(item_type);
  else:
    _set_tool_visible(HandheldItemType.None);
    _set_handheld_texture(item_type);


## @nullable [br]
## Returns the node object associated with [param item_type], or null if no association
## exists.
func get_tool_node(item_type: HandheldItemType) -> Node2D:
  return _item_nodes.get(item_type);


## Shows the handheld tool node described by [param item_type]. If no definition exists,
## the default, handheld_sprite, will be shown instead. Use [enum HandheldItemType.None]
## to choose the handheld_sprite specifically.
func _set_tool_visible(item_type: HandheldItemType) -> void:
  for child in get_children():
    child.hide();

  if _item_nodes.has(item_type):
    var tool_item := get_tool_node(item_type);
    tool_item.show();
  else:
    handheld_sprite.show();


## Changes the item texture for the handheld_sprite to one associated with
## [param item_type]. See [member item_textures] for definitions.
func _set_handheld_texture(item_type: HandheldItemType) -> void:
  var texture: Texture2D = item_textures.get(item_type);

  if texture:
    handheld_sprite.texture = texture;
  else:
    push_error('Could not set handheld texture: enum %s has no value.' % item_type);
