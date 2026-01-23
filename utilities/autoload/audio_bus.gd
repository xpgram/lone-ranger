## The global manager for audio objects.
extends Node


func _ready() -> void:
  Events.one_shot_sound_emitted.connect(_on_one_shot_sound_emitted);


func _on_one_shot_sound_emitted(audio_scene: PackedScene) -> void:
  var audio_player: AudioStreamPlayer = audio_scene.instantiate();
  add_child(audio_player);
