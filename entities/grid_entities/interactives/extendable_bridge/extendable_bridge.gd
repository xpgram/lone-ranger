extends Interactive2D

# [TODO] Allow drawing a path for this bridge, like the GrowTwig.


## If true, powering this device hides the bridge instead of extending it.
@export var _invert_power := false;


@onready var _sprite: Sprite2D = %Sprite2D;
@onready var _powerable: PowerableComponent = %PowerableComponent;


func _ready() -> void:
  _powerable.powered_on.connect(func (): _set_activated(true));
  _powerable.powered_off.connect(func (): _set_activated(false));


func _set_activated(value: bool) -> void:
  if _invert_power:
    value = !value;

  _sprite.visible = value;
  standable = value;
  # [TODO] Tell Grid to notify grid_position the floor has changed.
