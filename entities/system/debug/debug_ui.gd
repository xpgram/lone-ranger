extends Control


## Whether to show the debug panel on game start. In non-debug builds, does nothing.
@export var _show_debug_panel := false:
  set(value):
    _show_debug_panel = value;
    _set_visible(_show_debug_panel);


func _ready() -> void:
  _set_visible(_show_debug_panel);


func _unhandled_input(event: InputEvent) -> void:
  if not OS.is_debug_build():
    return;

  if event.is_pressed() and event.keycode == KEY_F1:
    _show_debug_panel = !_show_debug_panel;
    accept_event();


## Shows or hides the debug panel.
func _set_visible(visible_enabled: bool) -> void:
  if not visible_enabled:
    hide();
  else:
    show();
