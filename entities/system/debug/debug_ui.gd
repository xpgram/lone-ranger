extends Control


## Whether to show the debug panel on game start. In non-debug builds, does nothing.
@export var _show_debug_panel := false:
  set(value):
    _show_debug_panel = value;
    _set_visible(_show_debug_panel);


@onready var focus_node: FocusableControl = %FocusableControl;


func _ready() -> void:
  _set_visible(_show_debug_panel);


func _unhandled_input(event: InputEvent) -> void:
  if not OS.is_debug_build():
    return;

  if event is InputEventMouseButton:
    if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
      grab_focus();

  if event.pressed and event.keycode == KEY_F1:
    _show_debug_panel = !_show_debug_panel;
    accept_event();


## Shows or hides the debug panel.
func _set_visible(visible_enabled: bool) -> void:
  if not visible_enabled:
    hide();
  else:
    show();
