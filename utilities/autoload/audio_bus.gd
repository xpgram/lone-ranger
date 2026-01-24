## The global manager for audio objects.
extends Node


func _ready() -> void:
  Events.one_shot_sound_emitted.connect(_on_one_shot_sound_emitted);


func play_audio_scene(scene: PackedScene) -> AudioStreamPlayer:
  var audio_instance: AudioStreamPlayer = scene.instantiate();
  add_child(audio_instance);

  if not audio_instance.playing:
    audio_instance.play();

  return audio_instance;


func play_dynamic_audio_scene(scene: PackedScene) -> void:
  # TODO scene is of a special multi-track type that plays one or another
  #  audio track depending on its settings.
  pass


func _on_one_shot_sound_emitted(audio_scene: PackedScene) -> void:
  var audio_player: AudioStreamPlayer = audio_scene.instantiate();
  add_child(audio_player);
