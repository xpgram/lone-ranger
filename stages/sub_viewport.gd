extends SubViewport


func _process(delta: float) -> void:
  _emit_current_frame(delta);


## Emit a global signal carrying this frame's finish-rendered image and the
## time taken to produce it.
func _emit_current_frame(delta: float) -> void:
  var last_frame := get_texture().get_image();
  var last_frame_tex := ImageTexture.create_from_image(last_frame);
  Events.previous_frame_captured.emit(last_frame_tex, delta);
