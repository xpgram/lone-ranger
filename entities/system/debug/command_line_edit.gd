extends LineEdit


func _gui_input(event: InputEvent) -> void:
  if (
      event is InputEventKey
      and event.keycode in [KEY_UP, KEY_DOWN]
  ):
    # Ignore LineEdit's default behavior.
    accept_event();

    # [TODO] Move the LineEdit-specific functionality from debug_ui to in here.
    #
    # DebugCLI.History.cursor += 1;
    # Events.debug_move_history_cursor_up.emit();
    # Input.trigger_action('debug_cli_cursor_up') <- This isn't even a thing I can do.

    return;
