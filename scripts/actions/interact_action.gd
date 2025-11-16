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

  return entities.any(func (entity: GridEntity):
    return (
      # TODO What if I ever change the name of this node?
      entity.has_node('ContextAction')
      and (entity.get_node('ContextAction')).can_interact(playbill.performer)
    );
  );


func perform_async(playbill: FieldActionPlaybill) -> void:
  var interact_position := playbill.performer.faced_position;
  var entities := Grid.get_entities(interact_position);
  var interactive_idx := entities.find_custom(func (entity):
    return (
      entity.has_node('ContextAction')
      and (entity.get_node('ContextAction')).can_interact(playbill.performer)
    );
  );

  assert(interactive_idx >= 0,
    "Interact_FieldAction is trying to interact with a Grid position that has no context actions. coords: %s" % interact_position);
  
  var context_action := entities[interactive_idx].get_node('ContextAction') as ContextAction;

  @warning_ignore('redundant_await')
  await context_action.perform_interaction_async(playbill.performer);
