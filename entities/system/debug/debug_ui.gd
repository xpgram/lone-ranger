extends Control


## Whether to show the debug panel on game start. In non-debug builds, does nothing.
@export var _show_debug_panel := false:
  set(value):
    _show_debug_panel = value;
    _set_visible(_show_debug_panel);


@onready var _cmd_line: LineEdit = %CommandLineEdit;


func _ready() -> void:
  _set_visible(_show_debug_panel);

  _cmd_line.text_submitted.connect(_on_command_line_submitted);


func _unhandled_input(event: InputEvent) -> void:
  if not OS.is_debug_build():
    return;

  # if event is InputEventMouseButton:
  #   if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
  #     grab_focus();

  if event.pressed and event.keycode == KEY_F1:
    _show_debug_panel = true;
    accept_event();

  if event.pressed and event.keycode == KEY_F2:
    _show_debug_panel = true;
    _cmd_line.grab_focus();
    accept_event();

  if event.pressed and event.keycode == KEY_ESCAPE:
    if _cmd_line.has_focus():
      _cmd_line.release_focus();
      accept_event();
    elif _show_debug_panel == true:
      _show_debug_panel = false;
      accept_event();

  if has_focus():
    # [FIXME] This doesn't do anything, and I think that _might_ be because
    #   screen_shader gets to handle input first? I dunno.
    #   Notably, the player isn't arrow-key-movable while the LineEdit is focused.
    accept_event();


## Shows or hides the debug panel.
func _set_visible(visible_enabled: bool) -> void:
  if not visible_enabled:
    hide();
  else:
    show();


## Handler for submit events emitted from the command line node.
func _on_command_line_submitted(text: String) -> void:
  _cmd_line.text = "";
  Events.debug_command_submitted.emit(text);
  # [TODO] Implement a command history you can up arrow through.
