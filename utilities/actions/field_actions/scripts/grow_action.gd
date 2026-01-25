class_name Grow_FieldAction
extends FieldAction


const _scene_cast_audio := preload('uid://dje6ncwpv7kxg');


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var entities := Grid.get_entities(playbill.target_position);
  return entities \
    .any(func (entity: GridEntity): return entity is GrowableTwigEntity);


func perform_async(playbill: FieldActionPlaybill) -> bool:
  ActionUtils.play_cast_animation(playbill.performer, playbill.orientation);
  AudioBus.play_audio_scene(_scene_cast_audio);

  var entities := Grid.get_entities(playbill.target_position);
  
  for entity in entities:
    if entity is GrowableTwigEntity:
      entity.activate_growth_async();

  return true;
