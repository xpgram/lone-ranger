class_name Grow_FieldAction
extends FieldAction


const _scene_cast_audio := preload('uid://dje6ncwpv7kxg');


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var entities := Grid.get_entities(playbill.target_position);
  return entities \
    .any(func (entity: GridEntity): return entity.has_attribute('is_growable'));


func perform_async(playbill: FieldActionPlaybill) -> bool:
  ActionUtils.play_cast_animation(playbill.performer, playbill.orientation);
  AudioBus.play_audio_scene(_scene_cast_audio);

  # TODO This method should trigger a 'growth interact' on the object affected, and that
  #   object should do as it will, so that we can offer different kinds of growth behavior
  #   beyond path creation.

  var entities := Grid.get_entities(playbill.target_position);
  
  for entity in entities:
    if entity is GrowableTwigEntity:
      entity.activate_growth_async();

  return true;
