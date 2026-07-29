## @tool [br]
## 
@tool
class_name ExtendableBridgeEntity
extends Interactive2D

# [TODO] Allow drawing a path for this bridge, like the GrowTwig.
# [ ] A list of extended-to points.
# [ ] These are drawn/shown in-editor.
# [ ] _sprite is duplicated to each extended space.


## The [Grid]-positions this extendable bridge occupies.
##
## The `self` location is always included and need not be listed here.
@export var _multi_bridge_points := [] as Array[Vector2i]:
  set(value):
    _multi_bridge_points = value;
    queue_redraw();

## If true, powering this device hides the bridge instead of extending it.
@export var _invert_power := false;

## The time in seconds between each bridge piece revealing itself during the
## power-on or power-off animation.
@export var _bridge_reveal_step_time := 0.15;


@onready var _sprite: Sprite2D = %Sprite2D;
@onready var _powerable: PowerableComponent = %PowerableComponent;


func _ready() -> void:
  if Engine.is_editor_hint():
    return;

  _powerable.powered_on.connect(func (): _set_powered(true));
  _powerable.powered_off.connect(func (): _set_powered(false));

  _set_powered(false);


func _draw() -> void:
  if not Engine.is_editor_hint():
    return;

  _draw_multi_bridge_connecting_lines();
  _draw_multi_bridge_dots();


func _draw_multi_bridge_connecting_lines() -> void:
  var points := _get_multi_points_including_self();

  if points.size() <= 1:
    return;

  for i in range(1, points.size()):
    var pointA := Grid.get_world_coords(points[i - 1]);
    var pointB := Grid.get_world_coords(points[i]);
    draw_line(pointA, pointB, Color.YELLOW, 1.0);


func _draw_multi_bridge_dots() -> void:
  var points := _get_multi_points_including_self();

  if points.size() <= 1:
    return;

  for point in points:
    draw_circle(
      Grid.get_world_coords(point),
      1.5,
      Color.YELLOW,
    );


func _set_powered(value: bool) -> void:
  if _invert_power:
    value = !value;

  _sprite.visible = value;
  standable = value;
  # [TODO] Tell Grid to notify grid_position the floor has changed.


func _get_multi_points_including_self() -> Array[Vector2i]:
  var points := _multi_bridge_points.duplicate();
  if Vector2i.ZERO not in points:
    points.push_front(Vector2i.ZERO);
  return points;
