class_name PrintLog_FieldAction
extends FieldAction


func can_perform(_playbill: FieldActionPlaybill) -> bool:
  return true;


func perform_async(playbill: FieldActionPlaybill) -> bool:
  print('Using %s at %s...' % [action_name, playbill.target_position]);

  return true;
