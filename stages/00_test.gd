extends Node2D


const _scene_ambient_audio := preload('uid://0n3a34n32lmo');


func _ready() -> void:
  var audio_player := AudioBus.play_audio_scene(_scene_ambient_audio);

  audio_player.volume_linear = 0.0;

  var volume_tween := get_tree().create_tween();
  volume_tween.tween_property(audio_player, "volume_linear", 1.0, 4.0);
  volume_tween.play();
