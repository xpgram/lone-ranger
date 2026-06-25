extends OneShotEffect


const _scene_audio := preload('uid://bsrqiqwsnihg6');


func _ready() -> void:
  super._ready();
  AudioBus.play_audio_scene(_scene_audio);
