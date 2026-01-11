class_name Move_FieldAction
extends FieldAction


func can_perform(playbill: FieldActionPlaybill) -> bool:
  return ActionUtils.place_is_traversable(playbill.target_position, playbill.performer);


func perform_async(playbill: FieldActionPlaybill) -> void:
  var actor := playbill.performer;

  actor.grid_position = playbill.target_position;
  actor.faced_direction = playbill.orientation;
