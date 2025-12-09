class_name Spin_FieldAction
extends FieldAction


func can_perform(playbill: FieldActionPlaybill) -> bool:
  return (playbill.performer.faced_direction != playbill.orientation);


func perform_async(playbill: FieldActionPlaybill) -> void:
  var actor := playbill.performer;

  actor.faced_direction = playbill.orientation;

  if actor is Player2D:
    actor.set_animation_state('idle');
