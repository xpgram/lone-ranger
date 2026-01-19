class_name SwordStrike_FieldAction
extends FieldAction


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var target_entities := Grid.get_entities(playbill.target_position);
  var any_attackable_entity: bool = target_entities.any(func (entity: GridEntity): return Component.has_component(entity, HealthComponent));

  var is_facing_target: bool = (
    playbill.performer.grid_position + playbill.performer.faced_direction == playbill.target_position
  );

  return any_attackable_entity and is_facing_target;


func perform_async(playbill: FieldActionPlaybill) -> bool:
  ActionUtils.play_attack_animation(playbill.performer, playbill.orientation);

  var target_health_components := ActionUtils \
    .get_entity_health_components(Grid.get_entities(playbill.target_position));

  for health in target_health_components:
    health.value -= 1;

  return true;
