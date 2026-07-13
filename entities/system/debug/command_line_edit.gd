extends LineEdit


func _gui_input(event: InputEvent) -> void:
  if (
      not has_focus()
      or event is not InputEventKey
      or not event.pressed
  ):
    return;

  if event.keycode == KEY_UP:
    DebugCLI.History.cursor += 1;
    text = DebugCLI.History.get_cursor_line();
    accept_event();

  if event.keycode == KEY_DOWN:
    DebugCLI.History.cursor -= 1;
    text = DebugCLI.History.get_cursor_line();
    accept_event();

  if event.keycode == KEY_ESCAPE:
    release_focus();
    accept_event();


func reset_cmd_line() -> void:
  text = "";
  DebugCLI.History.reset_cursor();
