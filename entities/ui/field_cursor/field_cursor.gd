## Manages a cursor to select Grid positions. [br]
##
## Its base position is relative to a [member _origin_object], if one is provided,
## otherwise it uses the world origin.
class_name FieldCursor
extends Node2D


## TODO Also emit a chosen orientation. Player2D should choose its own faced_position, I think.
## Emitted when player input confirms a Grid coordinate.
signal grid_position_selected(grid_position: Vector2i);

## Emitted when the [FieldCursor] rejects UI control, e.g., when the player backs out until
## the cursor yields.
signal ui_canceled();


## A [Node2D] representing the positional origin for the [FieldCursor]. If unset, the
## cursor will use the world origin.
@export var _origin_object: Node2D;


## Control node representing input focus.
@onready var focus_node: FocusableControl = %FocusableControl;


func _ready() -> void:
  close();


func _unhandled_input(event: InputEvent) -> void:
  if not focus_node.has_focus():
    return;

  if event.is_action_pressed('move_up'):
    move_cursor(Vector2i.UP);
    focus_node.accept_event();
    return;

  elif event.is_action_pressed('move_down'):
    move_cursor(Vector2i.DOWN);
    focus_node.accept_event();
    return;

  elif event.is_action_pressed('move_left'):
    move_cursor(Vector2i.LEFT);
    focus_node.accept_event();
    return;

  elif event.is_action_pressed('move_right'):
    move_cursor(Vector2i.RIGHT);
    focus_node.accept_event();
    return;

  elif event.is_action_pressed('interact'):
    select_current_grid_position();
    focus_node.accept_event();
    return;

  elif event.is_action_pressed('cancel') \
      or event.is_action_pressed('open_action_menu'):
    cancel_ui_operation();
    focus_node.accept_event();
    return;


## Opens the cursor UI subsystem in a default configuration.
func open_from_start(_selection_map: Object = null) -> void:
  # TODO Get selectables map
  # - a 2D list of positions allowed to select
  # - an orientation? probably just part of the type
  # - a default cursor position (nullable)
  # Default selecatables map is 1x1 square over player with default cursor position over self.

  open();
  move_cursor_to_relative(Vector2i.ZERO);


## Opens the cursor UI subsystem in the same configuration it was closed with.
func open() -> void:
  show();
  focus_node.grab_focus();


## Closes the cursor UI subsystem and yields input focus.
func close() -> void:
  hide();
  focus_node.release_focus();


## Moves the cursor a number of tiles given by [param grid_vector] relative to its current
## grid position.
func move_cursor(grid_vector: Vector2i) -> void:
  var travel_vector := Grid.get_world_coords(grid_vector);
  position += Vector2(travel_vector);


## Moves the cursor to a specific [param grid_position] relative to its
## [member _origin_object]'s grid position.
func move_cursor_to_relative(grid_position: Vector2i) -> void:
  var relative_world_position := Grid.get_world_coords(grid_position);
  if _origin_object:
    relative_world_position += _origin_object.global_position;

  global_position = relative_world_position;


## Moves the cursor to a specific global [param grid_position], irrespective of its
## [member _origin_object]'s grid position.
func move_cursor_to_global(grid_position: Vector2i) -> void:
  var world_position := Grid.get_world_coords(grid_position);
  global_position = world_position;


## Returns the cursor's current Grid position as a [Vector2i].
func get_grid_coords() -> Vector2i:
  return Grid.get_grid_coords(global_position);


## Emits the cursor's current Grid position as the input player's target location.
func select_current_grid_position() -> void:
  var grid_position := Grid.get_grid_coords(global_position);
  grid_position_selected.emit(grid_position);


## Signals that the input player has backed out of the [FieldCursor] UI subsystem.
func cancel_ui_operation() -> void:
  close();
  ui_canceled.emit();
