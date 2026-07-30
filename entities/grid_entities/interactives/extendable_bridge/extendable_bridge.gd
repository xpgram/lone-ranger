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
# [ ] _piece_locations always includes grid_position: never an empty list.
# [ ] separate _bridge_piece_state: Array[bool].
# [ ] _extension_progress setter sets bools and queue's redraws when something is changed.
# [ ] self is inserted/removed according to bools as well.


const _texture_bridge_piece := preload('uid://bux7mk1j6iy44');


## The [Grid]-positions this extendable bridge occupies.
##
## The `self` location is always included and need not be listed here.
@export var _piece_locations := [Vector2i.ZERO] as Array[Vector2i]:
  set(value):
    if value.size() == 0:
      value = [Vector2i.ZERO];

    _piece_locations = value;
    queue_redraw();

## If true, powering this device hides the bridge instead of extending it.
@export var _invert_power := false;

## The time in seconds between each bridge piece revealing itself during the
## power-on or power-off animation.
@export_custom(PROPERTY_HINT_NONE, 'suffix:s')
var _bridge_reveal_step_time := 0.15;


##
var _bridge_piece_powered_states := [] as Array[bool];


##
var _extended_progress := 0.0:
  set(value):
    var minimum := 0;
    var maximum := _piece_locations.size() - 1;
    _extended_progress = clampf(value, minimum, maximum);

    var _insert_index := floori(_extended_progress);
    var _remove_index := ceili(_insert_index);

    if _extended_progress == minimum:
      _set_bridge_piece_on(minimum, false);
    elif _extended_progress == maximum:
      _set_bridge_piece_on(maximum, true);
    else:
      _set_bridge_piece_on(_insert_index, true);
      _set_bridge_piece_on(_remove_index, false);


@onready var _powerable: PowerableComponent = %PowerableComponent;


func _ready() -> void:
  if Engine.is_editor_hint():
    return;

  # [TODO] Remove self from grid_position _if_ it isn't in the list.

  _powerable.powered_on.connect(func (): _set_powered(true));
  _powerable.powered_off.connect(func (): _set_powered(false));

  _set_all_bridge_piece_states(false);
  _set_powered(false);

  tree_exiting.connect(_remove_self_from_multi_points);


func _draw() -> void:
  if Engine.is_editor_hint():
    _draw_editor_multi_bridge_other_locations();
  else:
    _draw_bridge_pieces();


func _draw_editor_multi_bridge_other_locations() -> void:
  if _piece_locations.size() <= 1:
    return;

  var texture_displacement := -Vector2.ONE * (Constants.GRID_SIZE / 2.0);

  for point in _piece_locations:
    draw_texture(
      _texture_bridge_piece,
      Grid.get_world_coords(point) + texture_displacement,
      Color(0.8, 0.8, 0.8, 0.5),
    );


func _draw_bridge_pieces() -> void:
  pass


func _set_all_bridge_piece_states(on: bool) -> void:
  for i in range(_bridge_piece_powered_states):
    _bridge_piece_powered_states[i] = on;


func _set_powered(value: bool) -> void:
  if _invert_power:
    value = !value;

  # standable = value;
  pass

  # [TODO] Queue the pop-in/out animation: tween _extended_progress.
  # [TODO] Tell Grid to notify grid_position the floor has changed.


func _set_bridge_piece_on(index: int, on: bool) -> void:
  if index < 0 or index >= _piece_locations.size():
    return;

  var previously_on := _bridge_piece_powered_states[index];
  if on == previously_on:
    return;

  var relative_point := _piece_locations[index];
  var grid_point = relative_point + grid_position;

  if on:
    Grid.put(self, grid_point);
  else:
    Grid.remove(self, grid_point);

  _bridge_piece_powered_states[index] = on;
  queue_redraw();


func _remove_self_from_multi_points() -> void:
  for point in _piece_locations:
    Grid.remove(self, point);


## Returns a list of Grid points excluding the [member grid_position] this
## entity already exists in.
func _get_grid_points_excluding_self() -> Array[Vector2i]:
  var points := _piece_locations.duplicate();

  points.assign(points
    .filter(func (point: Vector2i): return point != Vector2i.ZERO)
    .map(func (point: Vector2i): return point + grid_position)
  );

  return points;
