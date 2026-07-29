class_name ExtendableBridgeEntity
extends Interactive2D

# [TODO] Allow drawing a path for this bridge, like the GrowTwig.
# [ ] A list of extended-to points.
# [ ] These are drawn/shown in-editor.
# [ ] _sprite is duplicated to each extended space.


## The [Grid]-positions this extendable bridge occupies.
##
## The `self` location is always included and need not be listed here.
@export var _multi_bridge_points := [] as Array[Vector2i];

## If true, powering this device hides the bridge instead of extending it.
@export var _invert_power := false;

## The time in seconds between each bridge piece revealing itself during the
## power-on or power-off animation.
@export var _bridge_reveal_step_time := 0.15;


@onready var _sprite: Sprite2D = %Sprite2D;
@onready var _powerable: PowerableComponent = %PowerableComponent;


func _ready() -> void:
  _powerable.powered_on.connect(func (): _set_powered(true));
  _powerable.powered_off.connect(func (): _set_powered(false));

  _set_powered(false);


func _set_powered(value: bool) -> void:
  if _invert_power:
    value = !value;

  _sprite.visible = value;
  standable = value;
  # [TODO] Tell Grid to notify grid_position the floor has changed.
