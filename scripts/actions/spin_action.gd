class_name Spin_FieldAction
extends FieldAction


func action_name() -> String:
  return "Spin";


func action_description() -> String:
  return "Turn in place to face a new direction.";


func action_time_cost() -> float:
  return PartialTime.NONE;


func _can_perform() -> bool:
  return (_performer.facing_direction != _orientation);


func _perform_async() -> void:
  _performer.facing_direction = _orientation;
