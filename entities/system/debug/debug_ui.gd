extends Control


const MAX_CMD_HISTORY := 20;
const DEFAULT_CMD_INDEX := 0;

## Whether to show the debug panel on game start. In non-debug builds, does nothing.
@export var _show_debug_panel := false:
  set(value):
    _show_debug_panel = value;
    _set_visible(_show_debug_panel);


var _cmd_history := [] as Array[String];
var _cmd_history_index := DEFAULT_CMD_INDEX;


@onready var _cmd_line: LineEdit = %CommandLineEdit;


func _ready() -> void:
  _set_visible(_show_debug_panel);

  _cmd_line.text_submitted.connect(_on_command_line_submitted);


func _unhandled_input(event: InputEvent) -> void:
  if (
      not OS.is_debug_build()
      or not event.pressed
  ):
    return;

  if event.keycode == KEY_F1:
    _show_debug_panel = true;
    _cmd_line.grab_focus();
    accept_event();

  if event.keycode == KEY_F2:
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
      _move_up_cmd_history();
    if event.keycode == KEY_DOWN:
      _move_down_cmd_history();

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

  _cmd_history.push_back(text);
  if _cmd_history.size() > MAX_CMD_HISTORY:
    _cmd_history.pop_front();
  _cmd_history_index = DEFAULT_CMD_INDEX;


func _move_up_cmd_history() -> void:
  _cmd_history_index = clampi(_cmd_history_index + 1, DEFAULT_CMD_INDEX, _cmd_history.size());
  _cmd_line.text = _cmd_history[_cmd_history.size() - _cmd_history_index];


func _move_down_cmd_history() -> void:
  _cmd_history_index = clampi(_cmd_history_index - 1, DEFAULT_CMD_INDEX, _cmd_history.size());
  if _cmd_history_index == DEFAULT_CMD_INDEX:
    _cmd_line.text = "";
  else:
    _cmd_line.text = _cmd_history.get(_cmd_history.size() - _cmd_history_index);
