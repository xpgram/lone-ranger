## A unique FocusableControl that assumes focus when no other object has input focus.
extends FocusableControl


func _process(_delta: float) -> void:
  _grab_focus_when_focus_is_abandoned();


func _grab_focus_when_focus_is_abandoned() -> void:
  if not get_viewport().gui_get_focus_owner():
    grab_focus();
