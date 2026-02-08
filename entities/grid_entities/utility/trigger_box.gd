@tool
class_name TriggerBox
extends GridEntity


# TODO How will areas be handled? Do I really need a separate entity for each one?
#   If I'm not going to use an Area2D, then Grid will just have to notify 'something'.
#   'Something' can be a TriggerSpot, I guess, but if it didn't need 'solid' or 'pushable'
#   properties, that would be nice.
#   Or maybe... what if we allowed one GridEntity TriggerSpot to inhabit multiple places?
#   Hm...
#
#   o @export rect
#   o @tool draw rect boundaries
#   - drag hangles?
#   o Rect boundaries are turned into rect coordinates, iterated over
#   o All grid positions affected, trigger spot adds itself to.
#   o _tree_exit() -> removes references from all grid positions.
#   - Also, make sure inside->inside doesn't trigger a second entered() emission.
#     - How? Does it keep a list of references for who's in?
#     - Grid and GridEntity call remove() before put(), so how?
# TODO Implement into DemonWall boss, replacing the previous triggerspot.
# TODO Can we limit the overhead from being a GridEntity? TriggerSpots don't need "solid" or "pushable".
#   I wrote this somewhere:
#   - GridEntity will extend GridEntityAbstract, which makes base stipulations about the interface.
#     - GridEntity extends GridObject? GridObject being the thing Grid actually collates.
#   - GridEntity adds things like .solid and .pushable.
#   - TriggerBox extends GridEntityAbstract, and does not need to implement these things.
# TODO Implement NotifyEntity, a pair to Stimulus
#   I'm... not going to refactor Stimulus yet. I still need function signatures in the doc strings.
#   NotifyEntity.bumped(entities)         [Triggers a Stimulus reaction.]
#   NotifyEntity.secret_knocked(entities) [Collects and 'taps' a BumpComponent.]


var DEFAULT_EDITOR_BOX_COLOR := Color.from_rgba8(255, 255, 0, 128);


## Emitted when a [GridEntity] collides with this one.
signal entered(entity: GridEntity);

## Emitted when a [GridEntity] separates, or stops colliding with this one.
signal exited(entity: GridEntity);


## Describes the Grid area that colliding entities may trigger this box by entering.
## This [Rect2i]'s coordinates are relative to the object's position in the editor.
@export var _trigger_box_rect := Rect2i(0, 0, 1, 1):
  set(value):
    _trigger_box_rect = value;

    if Engine.is_editor_hint():
      queue_redraw();


# FIXME The Editor doesn't seem to interpret this as a default value. It's not resettable.
## The color of the trigger box area when drawn in the Editor.
@export var _trigger_box_color := DEFAULT_EDITOR_BOX_COLOR:
  set(value):
    _trigger_box_color = value;

    if Engine.is_editor_hint():
      queue_redraw();


func _ready() -> void:
  super._ready();
  _put_trigger_box_into_grid();


func _exit_tree() -> void:
  super._exit_tree();
  _remove_trigger_box_from_grid();


func _draw() -> void:
  _draw_trigger_box_rect();


func _bind_stimulus_callbacks() -> void:
  super._bind_stimulus_callbacks();
  _stimulus_event_map.add_events({
    Stimulus.entity_collision: _on_collision,
    Stimulus.entity_separation: _on_separation,
  });


func _on_collision(entity: GridEntity) -> void:
  entered.emit(entity);


func _on_separation(entity: GridEntity) -> void:
  exited.emit(entity);


## Puts 'self' into all affected trigger coordinates on the Grid. This allows the same
## entity to listen from multiple grid locations.
func _put_trigger_box_into_grid() -> void:
  if Engine.is_editor_hint():
    return;

  # FIXME GridEntity automatically handles put/remove when changing grid_position, but that
  #   isn't really necessary here, is it?
  #   Hahhh, I wish GDScript had interfaces...
  #   I think GridEntity should extend GridInterface, and so should other types, like whatever
  #   this trigger spot needs.
  # Remove self from the original grid position.
  Grid.remove(self, grid_position);

  # Put self in all coordinates described by the trigger box.
  var area_coords := _get_trigger_box_coordinates();
  for coord in area_coords:
    Grid.put(self, coord);


## Removes 'self' from all affected trigger coordinates in the Grid.
func _remove_trigger_box_from_grid() -> void:
  if Engine.is_editor_hint():
    return;

  var area_coords := _get_trigger_box_coordinates();
  for coord in area_coords:
    Grid.remove(self, coord);


## Returns a list of all Grid coordinates this [TriggerBox] listens to.
func _get_trigger_box_coordinates() -> Array[Vector2i]:
  var coords := [] as Array[Vector2i];

  var box_position := _trigger_box_rect.position + grid_position;

  for x in range(_trigger_box_rect.size.x):
    for y in range(_trigger_box_rect.size.y):
      coords.append(box_position + Vector2i(x, y));

  return coords;


## Draws the trigger box's bounds in the editor.
func _draw_trigger_box_rect() -> void:
  if not Engine.is_editor_hint():
    return;

  var half_grid_size := Vector2(Constants.GRID_SIZE, Constants.GRID_SIZE) / 2.0;
  var border := Vector2.ONE;

  var box_position := (Vector2(_trigger_box_rect.position) * Constants.GRID_SIZE);
  box_position -= half_grid_size;
  box_position += 2 * border;

  var box_size := Vector2(_trigger_box_rect.size) * Constants.GRID_SIZE;
  box_size = box_size.max(Vector2.ZERO);
  box_size = box_size - (3 * border);

  var display_rect := Rect2(
    box_position.x,
    box_position.y,
    box_size.x,
    box_size.y,
  );

  var display_color := _trigger_box_color if _trigger_box_color else DEFAULT_EDITOR_BOX_COLOR;

  draw_rect(display_rect, display_color);
