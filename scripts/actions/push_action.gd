class_name Push_FieldAction
extends FieldAction


func action_name() -> String:
  return "Push";


func action_description() -> String:
  return "Move a target one tile over.";


func action_time_cost() -> float:
  return PartialTime.FULL;


func can_perform(
  performer: GridEntity,
  target_position: Vector2i,
  _orientation: Vector2i,
) -> bool:
  var cell_entities := Grid.get_entities(target_position);

  var facing_target: bool = (
    performer.grid_position + performer.facing == target_position
  );

  var tile_obstructed: bool = (
    cell_entities.any(func (entity: GridEntity): return entity.obstructive)
  );

  return facing_target and tile_obstructed;


func perform_async(
  _performer: GridEntity,
  target_position: Vector2i,
  _orientation: Vector2i,
) -> void:
  # IMPLEMENT Pushing/bumping behavior.
  var entities := Grid.get_entities(target_position);
  print('Pushing %s...' % entities[0].name);
