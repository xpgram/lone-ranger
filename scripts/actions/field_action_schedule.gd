class_name FieldActionSchedule
extends RefCounted


## The action to perform.
var action: FieldAction;

## The itinerary describing from who and where this action is to be performed.
var playbill: FieldActionPlaybill;


@warning_ignore('shadowed_variable')
func _init(
  action: FieldAction,
  playbill: FieldActionPlaybill,
) -> void:
  self.action = action;
  self.playbill = playbill;
