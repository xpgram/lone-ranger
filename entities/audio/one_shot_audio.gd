class_name OneShotAudio
extends AudioStreamPlayer


func _ready() -> void:
  finished.connect(_on_audio_finished);

  # TODO How can I set a default like this that's still overridable?
  bus = 'SoundEffects';

  play();


func _on_audio_finished() -> void:
  queue_free();
