class_name PowerableDoorEntity
extends Interactive2D

# [TODO] Allow drawing a path for this door, like the GrowTwig.
#   Unlike ExtendableBridge, this is likely to be used for double-doors,
#   short lines, and maybe 2x2 areas.


## If true, powering this device hides the bridge instead of extending it.
@export var _invert_power := false;


@onready var _anim: AnimatedSprite2D = %AnimatedSprite2D;
@onready var _powerable: PowerableComponent = %PowerableComponent;


func _ready() -> void:
  _powerable.powered_on.connect(func (): _set_powered(true));
  _powerable.powered_off.connect(func (): _set_powered(false));

  _set_powered(false);


func _set_powered(value: bool) -> void:
  if _invert_power:
    value = !value;

  if value:
    _anim.play("raise")
  else:
    _anim.play_backwards("raise");

  solid = value;

  # [TODO] Tell Grid to notify grid_position that a wall has appeared.
  #   Actually, what should happen when this does? And can it be cool enough
  #   to inspire clever puzzle tech?
