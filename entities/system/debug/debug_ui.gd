extends Control


## Whether to show the debug panel on game start. In non-debug builds, does nothing.
@export var _show_debug_panel := false:
  set(value):
    _show_debug_panel = value;
    _set_visible(_show_debug_panel);


func _ready() -> void:
  _set_visible(_show_debug_panel);


func _unhandled_input(_event: InputEvent) -> void:
  if not OS.is_debug_build():
    return;

  # TODO Do input bindings matter? Should I want to enable DebugUI with a controller? (i.e., should I use param _event)
  if Input.is_key_pressed(KEY_F1):
    _show_debug_panel = !_show_debug_panel;
    accept_event();


## Shows or hides the debug panel.
func _set_visible(is_visible: bool) -> void:
  if not is_visible:
    hide();
  else:
    show();
