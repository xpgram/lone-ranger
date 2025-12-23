##
class_name MoveToward_FieldAction
extends FieldAction


func can_perform(playbill: FieldActionPlaybill) -> bool:
  return false;


func perform_async(playbill: FieldActionPlaybill) -> void:
  pass
