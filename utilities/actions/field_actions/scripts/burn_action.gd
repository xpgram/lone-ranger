class_name Burn_FieldAction
extends FieldAction


const _burn_audio_scene := preload('uid://x6flo6meb5s1');


func can_perform(_playbill: FieldActionPlaybill) -> bool:
  # TODO Does anything need to be checked here?
  #  Seems everything is covered by the inventory/field_cursor systems.
  return true;


func perform_async(playbill: FieldActionPlaybill) -> bool:
  ActionUtils.play_cast_animation(playbill.performer, playbill.orientation);
  Events.one_shot_sound_emitted.emit(_burn_audio_scene);

  var entities := Grid.get_entities(playbill.target_position);

  var health_components: Array[HealthComponent];
  health_components.assign(
    # TODO This is an annoying process. Can we simplify this filter/map pattern in Component.gd?
    entities
      .filter(func (entity: GridEntity): return Component.has_component(entity, HealthComponent))
      .map(func (entity: GridEntity): return Component.get_component(entity, HealthComponent))
  );

  for health_component in health_components:
    health_component.value -= 1;

  return true;
