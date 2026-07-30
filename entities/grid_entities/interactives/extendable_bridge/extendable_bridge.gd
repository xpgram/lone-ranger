## @tool [br]
##
@tool
class_name ExtendableBridgeEntity
extends Interactive2D

# [TODO] Allow drawing a path for this bridge, like the GrowTwig.
# [x] A list of extended-to points.
# [ ] These are drawn/shown in-editor.
# [ ] Multi-bridge fills other Grid locations and is usable by the player.
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

const _texture_origin := Vector2.ONE * (Constants.GRID_SIZE / 2.0);


## The [Grid]-positions this extendable bridge occupies.
@export var _piece_locations := [Vector2i.ZERO] as Array[Vector2i]:
  set(value):
    if value.size() == 0:
      value = [Vector2i.ZERO];

    _piece_locations = value;
    _construct_bridge_pieces();
    queue_redraw();

## If true, powering this device hides the bridge instead of extending it.
@export var _invert_power := false:
  set(value):
    _invert_power = value;
    queue_redraw();

## The time in seconds between each bridge piece revealing itself during the
## power-on or power-off animation.
@export_custom(PROPERTY_HINT_NONE, 'suffix:s')
var _bridge_reveal_step_time := 0.15;

##
var _bridge_pieces := [] as Array[BridgePiece];


##
var _extended_progress := 0.0:
  set(value):
    var minimum := 0;
    var maximum := _piece_locations.size() - 1;
    _extended_progress = clampf(value, minimum, maximum);

    var progress_index := (
      floori(_extended_progress) if _extended_progress > 0.0
      else -1
    );

    for i in range(_bridge_pieces.size()):
      var is_powered := (i <= progress_index);
      _bridge_pieces[i].powered = is_powered;


@onready var _powerable: PowerableComponent = %PowerableComponent;


func _ready() -> void:
  if Engine.is_editor_hint():
    return;

  _powerable.powered_on.connect(func (): _set_powered(true));
  _powerable.powered_off.connect(func (): _set_powered(false));

  _set_powered(false, true);

  tree_exiting.connect(_remove_self_from_grid);


func _draw() -> void:
  if Engine.is_editor_hint():
    _draw_editor_multi_bridge_other_locations();
  else:
    _draw_bridge_pieces();


func _draw_editor_multi_bridge_other_locations() -> void:
  for piece in _bridge_pieces:
    piece.draw_editor();


func _draw_bridge_pieces() -> void:
  for piece in _bridge_pieces:
    piece.draw();


func _set_powered(value: bool, skip_animation := false) -> void:
  if _invert_power:
    value = !value;

  if skip_animation:
    for piece in _bridge_pieces:
      piece.powered = value;
  else:
    # [TODO] Queue the pop-in/out animation: tween _extended_progress.
    for piece in _bridge_pieces:
      piece.powered = value;


func _construct_bridge_pieces() -> void:
  _bridge_pieces.assign(_piece_locations
    .map(func (location: Vector2i): return BridgePiece.new(self, location))
  );


func _remove_self_from_grid() -> void:
  for point in _piece_locations:
    Grid.remove(self, point);



## Private class to help model the bridge piece to piece manager relationship.
class BridgePiece extends RefCounted:
  var entity: ExtendableBridgeEntity;

  var powered := false:
    set(value):
      if (powered == value):
        return;

      powered = value;

      var grid_location := location + entity.grid_position;

      if powered:
        Grid.put(entity, grid_location);
      else:
        Grid.remove(entity, grid_location);

      # [TODO] Tell Grid to notify grid_position the floor has changed.
      entity.queue_redraw();

  var location: Vector2i;


  @warning_ignore("shadowed_variable")
  func _init(entity: ExtendableBridgeEntity, location: Vector2i) -> void:
    self.entity = entity;
    self.location = location;


  func draw() -> void:
    if not powered:
      return;

    entity.draw_texture(
      _texture_bridge_piece,
      Grid.get_world_coords(location) - _texture_origin,
    );


  func draw_editor() -> void:
    entity.draw_texture(
      _texture_bridge_piece,
      Grid.get_world_coords(location) - _texture_origin,
      Color(0.8, 0.8, 0.8, 0.5),
    );
