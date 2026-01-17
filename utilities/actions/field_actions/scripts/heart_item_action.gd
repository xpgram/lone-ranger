class_name HeartItem_FieldAction
extends FieldAction


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var actor := playbill.performer;

  if actor is not Player2D:
    return false;

  var health_component := Component.get_component(actor, HealthComponent) as HealthComponent;

  return (
    playbill.target_position == actor.grid_position
    and health_component.value < health_component.maximum
  );


func perform_async(playbill: FieldActionPlaybill) -> bool:
  var actor := playbill.performer;
  var health_component := Component.get_component(actor, HealthComponent) as HealthComponent;

  if health_component == null:
    return true;

  health_component.value += 2;

  return true;
