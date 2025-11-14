class_name Push_FieldAction
extends FieldAction


func action_name() -> String:
  return "Push";


func action_description() -> String:
  return "Move a target one tile over.";


func action_time_cost() -> float:
  return PartialTime.FULL;


func _can_perform() -> bool:
  var cell_entities := Grid.get_entities(_target_position);

  var facing_target: bool = (
    _performer.grid_position + _performer.facing_direction == _target_position
  );

  var tile_obstructed: bool = (
    cell_entities.any(func (entity: GridEntity): return entity.obstructive)
  );

  return facing_target and tile_obstructed;


func _perform_async() -> void:
  # IMPLEMENT Pushing/bumping behavior.
  var entities := Grid.get_entities(_target_position);
  print('Pushing %s...' % entities[0].name);
