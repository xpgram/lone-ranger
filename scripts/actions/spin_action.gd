class_name Spin_FieldAction
extends FieldAction


func action_name() -> String:
  return "Spin";


func action_description() -> String:
  return "Turn in place to face a new direction.";


func action_time_cost() -> float:
  return PartialTime.NONE;


func can_perform(
  performer: GridEntity,
  _target_position: Vector2i,
  orientation: Vector2i,
) -> bool:
  return (performer.facing != orientation);


func perform_async(
  performer: GridEntity,
  _target_position: Vector2i,
  orientation: Vector2i,
) -> void:
  performer.facing = orientation;
