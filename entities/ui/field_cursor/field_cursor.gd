##
class_name FieldCursor
extends Node2D


##
signal grid_position_selected(grid_position: Vector2i);

##
signal ui_canceled();


##
@export var _origin_object: Node2D;


## Control node representing input focus.
@onready var focus_node: FocusableControl = %FocusableControl;


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

  elif event.is_action_pressed('cancel'):
    cancel_ui_operation();
    focus_node.accept_event();
    return;


##
func open_from_start(_selection_map: Object = null) -> void:
  # Get selectables map
  # - a 2D list of positions allowed to select
  # - an orientation? probably just part of the type
  # - a default cursor position (nullable)
  # Default selecatables map is 1x1 square over player with default cursor position over self.

  open();
  move_cursor_to_relative(Vector2i.ZERO);


##
func open() -> void:
  show();
  focus_node.grab_focus();


##
func close() -> void:
  hide();
  focus_node.release_focus();


##
func move_cursor(grid_vector: Vector2i) -> void:
  var travel_vector := Grid.get_world_coords(grid_vector);
  position += Vector2(travel_vector);


##
func move_cursor_to_relative(relative_grid_position: Vector2i) -> void:
  var relative_world_position := Grid.get_world_coords(relative_grid_position);
  if _origin_object:
    relative_world_position += _origin_object.global_position;

  global_position = relative_world_position;


##
func move_cursor_to_global(grid_position: Vector2i) -> void:
  var world_position := Grid.get_world_coords(grid_position);
  global_position = world_position;


##
func get_grid_coords() -> Vector2i:
  return Grid.get_grid_coords(global_position);


##
func select_current_grid_position() -> void:
  var grid_position := Grid.get_grid_coords(global_position);
  grid_position_selected.emit(grid_position);


##
func cancel_ui_operation() -> void:
  ui_canceled.emit();
