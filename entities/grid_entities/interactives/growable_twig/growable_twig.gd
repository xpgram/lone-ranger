## A plant entity that is activated when 'grown' by spells or other means.
@tool
class_name GrowableTwigEntity
extends GridEntity


# FIXME This 'path2d' and its tool-related draw stuff should probably be a... resource? How do we draw, then?
## A list of Grid-position affected by the [GrowableTwigEntity] when activated.
@export var _platform_points: Array[Vector2i]:
  set(value):
    _platform_points = value;
    queue_redraw();


var _editor_selection_interface: EditorSelection;

## Whether to draw Grid-position dots showing which positions this [GrowableTwigEntity]
## affects when activated.
var _show_editor_path_dots := false:
  set(value):
    _show_editor_path_dots = value;
    queue_redraw();


func _ready() -> void:
  if not Engine.is_editor_hint():
    return;

  _connect_to_editor();


func _draw() -> void:
  if not Engine.is_editor_hint():
    return;

  _draw_editor_path_dots();


## Turns all affected growth points on the Grid into floor tiles if they can be.
func activate_growth_async() -> void:
  for relative_point in _platform_points:
    var grid_point := relative_point + grid_position;

    if ActionUtils.place_is_pit(grid_point):
      Grid.set_tile_type(grid_point, 1);

    await get_tree().create_timer(0.25).timeout;


## Gets editor interface references and connects to editor signals.
func _connect_to_editor() -> void:
  _editor_selection_interface = EditorInterface.get_selection();
  _editor_selection_interface.selection_changed.connect(_on_editor_selection_changed);


## If enabled, draws Grid-position dots in the Editor to show which positions are affected
## when this [GrowableTwigEntity] is activated.
func _draw_editor_path_dots() -> void:
  if not _show_editor_path_dots:
    return;

  for point in _platform_points:
    var world_point := Vector2(point * Constants.GRID_SIZE) + global_position;

    draw_circle(
      world_point,
      2.0,
      Color.YELLOW,
      true
    );


## Updates debug-draw settings when the editor's selected nodes are changed.
func _on_editor_selection_changed() -> void:
  var selected_nodes := _editor_selection_interface.get_selected_nodes();

  _show_editor_path_dots = (self in selected_nodes);
