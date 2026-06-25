class_name HeartItem_FieldAction
extends FieldAction


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var actor := playbill.performer;

  if actor is not Player2D:
    return false;

  var health := Component.getc(actor, HealthComponent) as HealthComponent;

  return (
    playbill.target_position == actor.grid_position
    and health.value < health.maximum
  );


func perform_async(playbill: FieldActionPlaybill) -> bool:
  var actor := playbill.performer;
  var health := Component.getc(actor, HealthComponent) as HealthComponent;

  if health == null:
    return true;

  health.value += 2;

  return true;
