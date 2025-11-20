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
  var actor := playbill.performer;

  actor.grid_position = playbill.target_position;
  actor.facing_direction = playbill.orientation;

  if actor is Player2D:
    actor.animation_player.reset();
    actor.animation_set_player.play('idle', actor.facing_direction);
