class_name OneShotAudio
extends AudioStreamPlayer


func _init() -> void:
  # TODO How can I set a default like this that's still overridable?
  bus = 'SoundEffects';


func _ready() -> void:
  finished.connect(_on_audio_finished);
  play();


func _on_audio_finished() -> void:
  queue_free();
