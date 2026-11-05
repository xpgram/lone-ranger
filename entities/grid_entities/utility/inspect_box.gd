## @tool [br]
## Used to block out areas of the Grid where inspection dialogue may be triggered.
## Useful for designing oneshot or bespoke Inspect descriptions for curious "objects"
## that are not actual GridEntities, such as a dark hallway or a mysterious room. [br]
##
## Note: The player "Inspects" one tile in front of them, so these inspection areas must
## be placed over what the player is looking at, not where they are.
@tool
class_name InspectBox
extends GridEntity


# [TODO] Factor out common elements between this and trigger_box.gd


var DEFAULT_EDITOR_BOX_COLOR := Color.from_rgba8(255, 255, 0, 128);


## Describes the Grid area where this box lives, and where players can interact
## with it. This [Rect2i]'s coordinates are relative to the object's position
## in the editor.
@export var _area_box_rect := Rect2i(0, 0, 1, 1):
  set(value):
    _area_box_rect = value;

    if Engine.is_editor_hint():
      queue_redraw();


# [FIXME] The Editor doesn't seem to interpret this as a default value. It's not resettable.
## The color of the area box when drawn in the Editor.
@export var _area_box_color := DEFAULT_EDITOR_BOX_COLOR:
  set(value):
    _area_box_color = value;

    if Engine.is_editor_hint():
      queue_redraw();


func _ready() -> void:
  super._ready();
  _put_area_box_into_grid();


func _exit_tree() -> void:
  super._exit_tree();
  _remove_area_box_from_grid();


func _draw() -> void:
  _draw_area_box_rect();


## Puts 'self' into all affected coordinates on the Grid. This allows the same
## entity to listen from multiple grid locations.
func _put_area_box_into_grid() -> void:
  if Engine.is_editor_hint():
    return;

  # [FIXME] This Grid.remove() is only necessary because GridObject automatically handles
  #   Grid placement when fiddling with its grid_position property.
  #   If there were an overridable method such as `GridObject.get_occupied_positions()`,
  #   then this object could simply define its shape and return it as a list of Vector2s.

  # Remove self from the original grid position.
  Grid.remove(self, grid_position);

  # Put self in all coordinates described by the area box.
  var area_coords := _get_area_box_coordinates();
  for coord in area_coords:
    Grid.put(self, coord);


## Removes 'self' from all affected coordinates in the Grid.
func _remove_area_box_from_grid() -> void:
  if Engine.is_editor_hint():
    return;

  var area_coords := _get_area_box_coordinates();
  for coord in area_coords:
    Grid.remove(self, coord);


## Returns a list of all Grid coordinates this object listens to.
func _get_area_box_coordinates() -> Array[Vector2i]:
  var coords := [] as Array[Vector2i];

  var box_position := _area_box_rect.position + grid_position;

  for x in range(_area_box_rect.size.x):
    for y in range(_area_box_rect.size.y):
      coords.append(box_position + Vector2i(x, y));

  return coords;


## Draws the area box's bounds in the editor.
func _draw_area_box_rect() -> void:
  if not Engine.is_editor_hint():
    return;

  var half_grid_size := Vector2(Constants.GRID_SIZE, Constants.GRID_SIZE) / 2.0;
  var border := Vector2.ONE;

  var box_position := (Vector2(_area_box_rect.position) * Constants.GRID_SIZE);
  box_position -= half_grid_size;
  box_position += 2 * border;

  var box_size := Vector2(_area_box_rect.size) * Constants.GRID_SIZE;
  box_size = box_size.max(Vector2.ZERO);
  box_size = box_size - (3 * border);

  var display_rect := Rect2(
    box_position.x,
    box_position.y,
    box_size.x,
    box_size.y,
  );

  var display_color := _area_box_color if _area_box_color else DEFAULT_EDITOR_BOX_COLOR;

  draw_rect(display_rect, display_color);
