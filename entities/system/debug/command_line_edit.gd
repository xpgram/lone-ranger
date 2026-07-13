extends LineEdit


func _gui_input(event: InputEvent) -> void:
  if (
      not has_focus()
      or event is not InputEventKey
      or not event.pressed
  ):
    return;

  if event.keycode == KEY_UP:
    _increment_history_cursor(1);
    accept_event();

  if event.keycode == KEY_DOWN:
    _increment_history_cursor(-1)
    accept_event();

  if event.keycode == KEY_ESCAPE:
    release_focus();
    accept_event();


## Resets the command line to base conditions.
func reset_cmd_line() -> void:
  text = "";
  DebugCLI.History.reset_cursor();


## Moves the history cursor and assumes the text of that historical element.
func _increment_history_cursor(paces: int) -> void:
  DebugCLI.History.cursor += paces;
  text = DebugCLI.History.get_cursor_line();
  caret_column = text.length();
