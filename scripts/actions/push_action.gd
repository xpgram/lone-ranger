class_name Push_FieldAction
extends FieldAction


func action_name() -> String:
  return "Push";


func action_description() -> String:
  return "Move a target one tile over.";


func action_time_cost() -> float:
  return PartialTime.FULL;


func can_perform(playbill: FieldActionPlaybill,) -> bool:
  var cell_entities := Grid.get_entities(playbill.target_position);

  var facing_target: bool = (
    playbill.performer.grid_position + playbill.performer.facing_direction == playbill.target_position
  );

  var tile_obstructed: bool = (
    cell_entities.any(func (entity: GridEntity): return entity.obstructive)
  );

  return facing_target and tile_obstructed;


func perform_async(playbill: FieldActionPlaybill,) -> void:
  # IMPLEMENT Pushing/bumping behavior.
  var entities := Grid.get_entities(playbill.target_position);
  print('Pushing %s...' % entities[0].name);
