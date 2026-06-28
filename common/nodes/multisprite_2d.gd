@tool
## A [Sprite2D] that keeps a dictionary of available textures accessible by key. [br]
##
## The preferred method of setting textures via code is via [member texture_key] — setting
## [member texture] directly may cause [member texture_key] to become unsynced.
class_name MultiSprite2D
extends Sprite2D


## The dictionary key for the currently displayed texture.
@export var texture_key: StringName = '':
  set(value):
    if not textures.has(value):
      return;

    texture_key = value;
    texture = textures[texture_key];


## A dictionary of all textures available to this sprite object.
@export var textures: Dictionary[StringName, Texture2D] = {}:
  set(value):
    var dict_was_empty := (textures.size() == 0);
    textures = value;

    if dict_was_empty and textures.size() > 0:
      texture_key = textures.keys()[0];
