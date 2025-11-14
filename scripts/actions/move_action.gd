class_name Move_FieldAction
extends FieldAction


func action_name() -> String:
  return "Move";


func action_description() -> String:
  return "Moves the target one tile on the field.";


func action_time_cost() -> float:
  return PartialTime.FULL;


func can_perform(
  _performer: GridEntity,
  target_position: Vector2i,
  _orientation: Vector2i,
) -> bool:
  var cell_entities := Grid.get_entities(target_position);

  var tile_unobstructed: bool = (
    cell_entities.all(func (entity: GridEntity): return not entity.obstructive)
  );

  return tile_unobstructed;


func perform_async(
  performer: GridEntity,
  target_position: Vector2i,
  orientation: Vector2i,
) -> void:
  performer.grid_position = target_position;
  performer.facing_direction = orientation;
