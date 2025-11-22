class_name Interact_FieldAction
extends FieldAction


# TODO Implement variable action_time_costs.
#   As far as I know, this is the only FieldAction that *needs* this functionality,
#   though there are others that could benefit from it.
#   The problem is that Dialogue shouldn't cost time, but opening a chest should cost a
#   full turn.
#
#   [Note: Actually, ItemUse_FieldAction is another that would benefit from this.
#    Using a 'Potion' should definitely be a full-time cost, but unlocking a door with a
#    key maybe shouldn't.]
#
#   An alternative could be dividing context actions into InteractTimeAction and
#   InteractFreeAction that check their ContextAction nodes for which kind it is,
#   but that could be kind of annoying.
#
#   Another alternative is keeping a private _action_time_cost that is updated first-thing
#   by perform_async using a number it finds in the ContextAction, and this would be
#   returned by action_time_cost() when it's called later.
#   This creates a call-order dependency on these two functions, though, that I really
#   don't like.
#
#   An alternative-alternative to the last idea is to keep a get_variable_time_cost() that
#   explicitly declares its purpose and usage, I guess.
#   ...
#   *sigh*, I don't really hate this idea...
#
#   How would the TurnManager know which time_cost() function to call, though?
#   Or rather, why wouldn't it just always call the variable one?
#
#   Um... We could set a flag, or we could define an inheritance type. TurnManager would
#   know by checking first which action it's "speaking" to.
#   Final question: is this over-engineered? There also isn't a reason not to call
#   variable_time_cost every time.


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
