class_name Interact_FieldAction
extends FieldAction


func action_name() -> String:
  return "Interact";


func action_description() -> String:
  return "Perform context actions in the field.";


func action_time_cost() -> float:
  return PartialTime.NONE;


func can_perform(playbill: FieldActionPlaybill) -> bool:
  var entities := Grid.get_entities(playbill.performer.faced_position);

  return entities.any(func (entity):
    return (
      is_instance_of(entity, InteractiveGridEntity)
      and (entity as InteractiveGridEntity).can_interact(playbill.performer)
    );
  );


func perform_async(playbill: FieldActionPlaybill) -> void:
  var entities := Grid.get_entities(playbill.performer.faced_position);
  var interactive_idx := entities.find_custom(func (entity):
    return is_instance_of(entity, InteractiveGridEntity)
  );

  assert(interactive_idx >= 0,
    "Interact_FieldAction is trying to interact with a Grid position that has no interactibles.");
  
  var interactive_entity := entities[interactive_idx] as InteractiveGridEntity;

  @warning_ignore('redundant_await')
  await interactive_entity.perform_interaction_async(playbill.performer);
