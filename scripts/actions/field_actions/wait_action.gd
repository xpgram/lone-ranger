## The "non-action" action. Do nothing.
class_name Wait_FieldAction
extends FieldAction


func can_perform(_playbill: FieldActionPlaybill) -> bool:
  return true;


func perform_async(_playbill: FieldActionPlaybill) -> void:
  pass;
