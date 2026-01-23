extends AudioStreamPlayer


func _ready() -> void:
  finished.connect(_on_audio_finished);


func _on_audio_finished() -> void:
  queue_free();
