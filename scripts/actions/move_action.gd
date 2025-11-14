class_name Move_FieldAction
extends FieldAction


func action_name() -> String:
  return "Move";


func action_description() -> String:
  return "Moves the target one tile on the field.";


func action_time_cost() -> float:
  return PartialTime.FULL;


func _can_perform() -> bool:
  var cell_entities := Grid.get_entities(_target_position);

  var tile_unobstructed: bool = (
    cell_entities.all(func (entity: GridEntity): return not entity.obstructive)
  );

  return tile_unobstructed;


func _perform_async() -> void:
  _performer.grid_position = _target_position;
  _performer.facing_direction = _orientation;
