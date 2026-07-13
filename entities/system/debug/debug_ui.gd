extends Control


## Whether to show the debug panel on game start. In non-debug builds, does nothing.
@export var _show_debug_panel := false:
  set(value):
    _show_debug_panel = value;
    _set_visible(_show_debug_panel);


@onready var _background: ColorRect = %DebugBackground;
@onready var _cmd_line: LineEdit = %CommandLineEdit;


func _ready() -> void:
  _set_visible(_show_debug_panel);

  _cmd_line.focus_entered.connect(_on_cmd_focus_entered);
  _cmd_line.focus_exited.connect(_on_cmd_focus_exited);
  _cmd_line.text_submitted.connect(_on_command_line_submitted);


func _unhandled_input(event: InputEvent) -> void:
  if (
      not OS.is_debug_build()
      or event is not InputEventKey
      or not event.pressed
  ):
    return;

  if event.keycode == KEY_F1:
    if not _show_debug_panel:
      _cmd_line.reset_cmd_line();
      _show_debug_panel = true;
    else:
      _cmd_line.grab_focus();
    accept_event();

  if event.keycode == KEY_ESCAPE:
    if _show_debug_panel == true:
      _show_debug_panel = false;
      accept_event();


## Shows or hides the debug panel.
func _set_visible(visible_enabled: bool) -> void:
  if not visible_enabled:
    hide();
  else:
    show();


## Handler for command-line focused events.
func _on_cmd_focus_entered() -> void:
  _background.color.a = 1.0;
  # _background.size.y = 16 * 3.5;


## Handler for command-line focus-exited events.
func _on_cmd_focus_exited() -> void:
  _background.color.a = 0.5;
  # _background.size.y = 16;


## Handler for submit events emitted from the command line node.
func _on_command_line_submitted(input: String) -> void:
  DebugCLI.History.append(input);
  DebugCLI.History.reset_cursor();
  _cmd_line.text = "";
  # DebugCLI.process(input);
  Events.debug_command_submitted.emit(input);
