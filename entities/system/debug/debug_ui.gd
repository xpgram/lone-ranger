extends Control


func _ready() -> void:
  hide();
  show(); # TODO Remove this line.


func _unhandled_input(_event: InputEvent) -> void:
  # TODO Do input bindings matter? Should I want to enable DebugUI with a controller? (i.e., should I use param _event)
  if Input.is_key_pressed(KEY_F1):
    visible = !visible;
    accept_event();
