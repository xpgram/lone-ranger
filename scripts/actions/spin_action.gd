class_name Spin_FieldAction
extends FieldAction


func action_name() -> String:
  return "Spin";


func action_description() -> String:
  return "Turn in place to face a new direction.";


func action_time_cost() -> float:
  return PartialTime.NONE;


func can_perform(playbill: FieldActionPlaybill) -> bool:
  return (playbill.performer.faced_direction != playbill.orientation);


func perform_async(playbill: FieldActionPlaybill) -> void:
  var actor := playbill.performer;

  actor.faced_direction = playbill.orientation;

  if actor is Player2D:
    actor.animation_player.reset();
    actor.animation_set_player.play('idle', actor.faced_direction);
