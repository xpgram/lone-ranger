## The "non-action" action. Do nothing.
class_name Wait_FieldAction
extends FieldAction


func action_name() -> String:
  return "Wait";


func action_description() -> String:
  return "Sit idly in place.";


func action_time_cost() -> float:
  return PartialTime.NONE;


func can_perform(
  _performer: GridEntity,
  _target_position: Vector2i,
  _orientation: Vector2i,
) -> bool:
  return true;


func perform_async(
  _performer: GridEntity,
  _target_position: Vector2i,
  _orientation: Vector2i,
) -> void:
  pass;
