## @tool [br]
## A class to describe a bridge [Interactive2D] that may be powered on and off
## and which animates open or closed depending on its power state.
@tool
class_name ExtendableBridgeEntity
extends Interactive2D


## The [Texture] resource used to display the bridge pieces.
const _texture_bridge_piece := preload('uid://bux7mk1j6iy44');

## The draw-origin of the texture used to display bridge pieces.
const _texture_origin := Vector2.ONE * (Constants.GRID_SIZE / 2.0);


## The [Grid]-positions this extendable bridge occupies.
@export var _piece_locations := [Vector2i.ZERO] as Array[Vector2i]:
  set(value):
    _piece_locations = value;
    _construct_bridge_pieces();
    queue_redraw();

## If true, powering this device hides the bridge instead of extending it.
@export var _invert_power := false;

## The time in seconds between each bridge piece revealing itself during the
## power-on or power-off animation.
@export_custom(PROPERTY_HINT_NONE, 'suffix:s')
var _bridge_reveal_step_time := 0.1;

## A list of [BridgePieces] constructed from the list of [member _piece_locations].
var _bridge_pieces := [] as Array[BridgePiece];

## How extended this bridge is. This value ranges from `0` (fully closed) to
## `_piece_locations.size()` (fully open).
var _extended_progress := 0.0:
  set(value):
    var minimum := 0;
    var maximum := _piece_locations.size();
    _extended_progress = clampf(value, minimum, maximum);

    var progress_index := (
      floori(_extended_progress) if _extended_progress > 0.0
      else -1
    );

    for i in range(_bridge_pieces.size()):
      var is_powered := (i <= progress_index);
      _bridge_pieces[i].powered = is_powered;

## @nullable [br]
## A reference to the current [Tween] for [member _extended_progress].
var _active_progress_tween: Tween;


@onready var _powerable: PowerableComponent = %PowerableComponent;


func _ready() -> void:
  _construct_bridge_pieces();

  if Engine.is_editor_hint():
    return;

  _powerable.powered_on.connect(func (): _set_powered(true));
  _powerable.powered_off.connect(func (): _set_powered(false));

  _set_powered(false, true);

  tree_exiting.connect(_remove_self_from_grid);


func _draw() -> void:
  if Engine.is_editor_hint():
    _draw_editor_bridge_pieces();
  else:
    _draw_bridge_pieces();


## Draws the Bridge in editor view.
func _draw_editor_bridge_pieces() -> void:
  for piece in _bridge_pieces:
    piece.draw_editor();


## Draws the Bridge in game view.
func _draw_bridge_pieces() -> void:
  for piece in _bridge_pieces:
    piece.draw();


## Sets the powered-state of the Bridge, triggering the open/close animation
## accordingly. Skips the animation if [member skip_animation] is `true`.
func _set_powered(value: bool, skip_animation := false) -> void:
  if _invert_power:
    value = !value;

  if skip_animation:
    for piece in _bridge_pieces:
      piece.powered = value;
  else:
    if _active_progress_tween:
      _active_progress_tween.kill();

    var maximum := _piece_locations.size() as float;
    var final_value := maximum if value else 0.0;
    var travel_distance := absf(final_value - _extended_progress);
    var total_time := travel_distance * _bridge_reveal_step_time;

    _active_progress_tween = get_tree().create_tween();
    _active_progress_tween.tween_property(self, "_extended_progress", final_value, total_time);


## Constructs the list of [member _bridge_pieces] from the editor export list
## of [member _piece_locations].
func _construct_bridge_pieces() -> void:
  _bridge_pieces.assign(_piece_locations
    .map(func (location: Vector2i): return BridgePiece.new(self, location))
  );


## Removes this entity from all its occupied locations on the [Grid].
func _remove_self_from_grid() -> void:
  for point in _piece_locations:
    Grid.remove(self, point);



## Private class to help model the bridge piece to piece manager relationship.
class BridgePiece extends RefCounted:
  var entity: ExtendableBridgeEntity;

  ## Whether this BridgePiece is active. If `true`, sets the [ExtendableBridge]
  ## into the [Grid], else removes it. Queues a redraw of the entity when the
  ## value is successfully changed.
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

  ## Where on the [Grid] this [BridgePiece] is located, relative to the origin
  ## of [member entity].
  var location: Vector2i;


  @warning_ignore("shadowed_variable")
  func _init(entity: ExtendableBridgeEntity, location: Vector2i) -> void:
    self.entity = entity;
    self.location = location;


  ## Draw the BridgePiece in game view.
  func draw() -> void:
    if not powered:
      return;

    _draw_texture();


  ## Draw the BridgePiece in editor view.
  func draw_editor() -> void:
    _draw_texture(Color(0.8, 0.8, 0.8, 0.5));


  ## Draws the bridge-piece texture via the owner [member entity] with the
  ## [param modulate] color.
  func _draw_texture(modulate := Color.WHITE) -> void:
    entity.draw_texture(
      _texture_bridge_piece,
      Grid.get_world_coords(location) - _texture_origin,
      modulate,
    );
