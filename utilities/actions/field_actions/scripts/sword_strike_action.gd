class_name SwordStrike_FieldAction
extends FieldAction


const _scene_cast_audio := preload('uid://gp5umbprfog6');


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var target_entities := Grid.get_entities(playbill.target_position);
  var any_attackable_entity: bool = target_entities.any(func (entity: GridEntity): return Component.has_component(entity, HealthComponent));

  var is_facing_target: bool = (
    playbill.performer.grid_position + playbill.performer.faced_direction == playbill.target_position
  );

  return any_attackable_entity and is_facing_target;


func perform_async(playbill: FieldActionPlaybill) -> bool:
  ActionUtils.play_attack_animation(playbill.performer, playbill.orientation);
  AudioBus.play_audio_scene(_scene_cast_audio);

  var target_entities := Grid.get_entities(playbill.target_position);
  var target_health_components := Component.get_all(target_entities, HealthComponent);

  for health: HealthComponent in target_health_components:
    health.value -= 1;

  return true;
