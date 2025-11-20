## The "non-action" action. Do nothing.
class_name Wait_FieldAction
extends FieldAction


func action_name() -> String:
  return "Wait";


func action_description() -> String:
  return "Sit idly in place.";


func action_time_cost() -> float:
  return PartialTime.NONE;


func can_perform(_playbill: FieldActionPlaybill) -> bool:
  return true;


func perform_async(_playbill: FieldActionPlaybill) -> void:
  pass;
