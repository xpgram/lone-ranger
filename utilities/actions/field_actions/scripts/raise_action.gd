class_name Raise_FieldAction
extends FieldAction


const _raised_block_scene := preload('uid://c6rlkogh1433o');


func can_perform(playbill: FieldActionPlaybill) -> bool:
  return (
    not ActionUtils.place_is_obstructed(playbill.target_position)
    and ActionUtils.place_is_floor(playbill.target_position)
  );


func perform_async(playbill: FieldActionPlaybill) -> bool:
  var raised_block := _raised_block_scene.instantiate();
  # FIXME This adds the block to the PlayerModule instead of the entities node.
  playbill.performer.add_sibling(raised_block);

  raised_block.grid_position = playbill.target_position;

  _trigger_dig_effects(playbill.target_position);

  return true;


func _trigger_dig_effects(place: Vector2i) -> void:
  var entities := Grid.get_entities(place);

  for entity in entities:
    if entity is DiggableSpotEntity:
      entity.on_spell_activated__raise();
