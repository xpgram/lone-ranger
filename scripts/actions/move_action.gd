class_name Move_FieldAction
extends FieldAction


func action_name() -> String:
  return "Move";


func action_description() -> String:
  return "Moves the target one tile on the field.";


func action_time_cost() -> float:
  return PartialTime.FULL;


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var cell_entities := Grid.get_entities(playbill.target_position);

  var tile_unobstructed: bool = (
    cell_entities.all(func (entity: GridEntity): return not entity.obstructive)
  );

  return tile_unobstructed;


func perform_async(playbill: FieldActionPlaybill) -> void:
  playbill.performer.grid_position = playbill.target_position;
  playbill.performer.facing_direction = playbill.orientation;
