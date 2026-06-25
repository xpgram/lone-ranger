@tool
extends TriggerBox


const _scene_growl_audio := preload('uid://gefct2wfm524');

var _sound_played := false;


func _ready() -> void:
  super._ready();
  entered.connect(_on_entered);


func _on_entered(entity: GridEntity) -> void:
  if not entity is Player2D:
    return;
  
  var inventory := (entity as Player2D).inventory;

  if (
      not _sound_played
      and inventory.has_equipment(PlayerEquipment.hookshot)
      and inventory.has_equipment(PlayerEquipment.wings)
  ):
    AudioBus.play_audio_scene(_scene_growl_audio, 0.6);
    _sound_played = true;
    queue_free();
