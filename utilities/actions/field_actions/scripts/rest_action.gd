## The "I'm stuck!" action to reset the player state. [br]
##
## Technically, this is like casting "Sleep" on self, so it could be expanded later, maybe.
class_name Rest_FieldAction
extends FieldAction


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var is_player := (playbill.performer is Player2D);
  var is_targeting_self := (playbill.performer.grid_position == playbill.target_position);
  return is_player and is_targeting_self;


func perform_async(playbill: FieldActionPlaybill) -> bool:
  var actor := playbill.performer;

  if actor is Player2D:
    # TODO Play an actual sleep animation.
    actor.faced_direction = Vector2i.DOWN;
    actor.trigger_rest_and_reset_state();

  return true;
