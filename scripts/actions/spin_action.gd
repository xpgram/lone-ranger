class_name Spin_FieldAction
extends FieldAction


func action_name() -> String:
  return "Spin";


func action_description() -> String:
  return "Turn in place to face a new direction.";


func action_time_cost() -> float:
  return PartialTime.NONE;


func can_perform(playbill: FieldActionPlaybill) -> bool:
  return (playbill.performer.facing_direction != playbill.orientation);


func perform_async(playbill: FieldActionPlaybill) -> void:
  playbill.performer.facing_direction = playbill.orientation;
