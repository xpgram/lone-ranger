## A [FieldAction] that always refuses to assume behavior control.
class_name Null_FieldAction
extends FieldAction


func can_perform(_playbill: FieldActionPlaybill) -> bool:
  return false;


func perform_async(_playbill: FieldActionPlaybill) -> bool:
  return false;
