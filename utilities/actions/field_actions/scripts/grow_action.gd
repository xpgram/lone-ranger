class_name Grow_FieldAction
extends FieldAction


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var entities := Grid.get_entities(playbill.target_position);
  return entities \
    .any(func (entity: GridEntity): return entity is GrowableTwigEntity);


func perform_async(playbill: FieldActionPlaybill) -> bool:
  ActionUtils.play_cast_animation(playbill.performer, playbill.orientation);

  var entities := Grid.get_entities(playbill.target_position);
  
  for entity in entities:
    if entity is GrowableTwigEntity:
      entity.activate_growth_async();

  return true;
