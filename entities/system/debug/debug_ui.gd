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
  if (
      not OS.is_debug_build()
      or event is not InputEventKey
      or not event.pressed
  ):
    return;

  if event.keycode == KEY_F1:
    if _show_debug_panel:
      _cmd_line.grab_focus();
    else:
      _show_debug_panel = true;
    accept_event();

  if event.keycode == KEY_ESCAPE:
    if _cmd_line.has_focus():
      _cmd_line.release_focus();
      accept_event();
    elif _show_debug_panel == true:
      _show_debug_panel = false;
      accept_event();

  if _cmd_line.has_focus():
    if event.keycode == KEY_UP:
      DebugCLI.History.cursor += 1;
      _cmd_line.text = DebugCLI.History.get_cursor_line();
    if event.keycode == KEY_DOWN:
      DebugCLI.History.cursor -= 1;
      _cmd_line.text = DebugCLI.History.get_cursor_line();

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
func _on_command_line_submitted(input: String) -> void:
  DebugCLI.History.append(input);
  DebugCLI.History.reset_cursor();
  _cmd_line.text = "";
  # DebugCLI.process(input);
  Events.debug_command_submitted.emit(input);
