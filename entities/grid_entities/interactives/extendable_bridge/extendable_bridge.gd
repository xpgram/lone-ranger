## @tool [br]
##
# @tool
class_name ExtendableBridgeEntity
extends Interactive2D

# [TODO] Allow drawing a path for this bridge, like the GrowTwig.
# [x] A list of extended-to points.
# [x] These are drawn/shown in-editor.
# [x] Multi-bridge fills other Grid locations and is usable by the player.
# [ ] _sprite is duplicated to each extended space.
#
#
# I don't like how this is working so far. It's too complicated.
# [ ] Remove _sprite, but @export a texture field.
# [ ] _multi_bridge_points always includes grid_position: never an empty list.
# [ ] separate _bridge_piece_state: Array[bool].
# [ ] _extension_progress setter sets bools and queue's redraws when something is changed.
# [ ] self is inserted/removed according to bools as well.


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


var _extended_progress := 0.0;


@onready var _sprite: Sprite2D = %Sprite2D;
@onready var _powerable: PowerableComponent = %PowerableComponent;


func _ready() -> void:
  if Engine.is_editor_hint():
    return;

  _powerable.powered_on.connect(func (): _set_powered(true));
  _powerable.powered_off.connect(func (): _set_powered(false));

  tree_exiting.connect(_remove_self_from_multi_points);

  _add_self_to_multi_points();
  _set_powered(false);


func _draw() -> void:
  if not Engine.is_editor_hint():
    return;

  _draw_multi_bridge_other_locations();


func _draw_multi_bridge_other_locations() -> void:
  if _multi_bridge_points.size() <= 1:
    return;

  var texture_displacement := -Vector2.ONE * (Constants.GRID_SIZE / 2.0);

  for point in _multi_bridge_points:
    draw_texture(
      _sprite.texture,
      Grid.get_world_coords(point) + texture_displacement,
      Color(0.8, 0.8, 0.8, 0.5),
    );


func _set_powered(value: bool) -> void:
  if _invert_power:
    value = !value;

  _sprite.visible = value;
  standable = value;
  # [TODO] Queue the pop-in/out animation: tween _extended_progress.
  # [TODO] Tell Grid to notify grid_position the floor has changed.


func _add_self_to_multi_points() -> void:
  var points := _get_grid_points_excluding_self();

  for point in points:
    Grid.put(self, point);


func _remove_self_from_multi_points() -> void:
  var points := _get_grid_points_excluding_self();

  for point in points:
    Grid.remove(self, point);


## Returns a list of Grid points excluding the [member grid_position] this
## entity already exists in.
func _get_grid_points_excluding_self() -> Array[Vector2i]:
  var points := _multi_bridge_points.duplicate();

  points.assign(points
    .filter(func (point: Vector2i): return point != Vector2i.ZERO)
    .map(func (point: Vector2i): return point + grid_position)
  );

  return points;
