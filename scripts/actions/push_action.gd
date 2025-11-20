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
  var actor := playbill.performer;
  actor.facing_direction = playbill.orientation;

  var entities := Grid.get_entities(playbill.target_position);

  # IMPLEMENT Pushing/bumping behavior.
  # grid_entity.push(direction) -> trigger movement, bump if it can't, animation state
  print('Pushing %s...' % entities[0].name);

  if actor is Player2D:
    actor.animation_player.reset();
    actor.animation_set_player.play('push', actor.facing_direction);
