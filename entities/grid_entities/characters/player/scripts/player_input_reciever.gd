## Recieves and delegates user input to any controlled [Player2D] objects.
class_name PlayerInputReciever
extends Node



func _catch_input_focus_when_focus_lost() -> void:
  if not get_viewport().gui_get_focus_owner():
    focus_node.grab_focus();
