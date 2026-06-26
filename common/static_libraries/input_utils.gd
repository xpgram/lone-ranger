## A static library for common Input-related operations.
class_name InputUtils


# [TODO] Do InputEvents not carry their action names because they can relate to multiple?
#   This is why I wrote get_all_input_action_names(), but I haven't proven that it's
#   necessary yet.


## Returns the first encountered [InputMap] action associated with [param event].
## Returns an empty [StringName] if no actions could be matched. [br]
##
## Note that 'first' is not well defined and is ideal only in cases where a given
## [InputEvent] has at most 1 actions it is associated with.
static func get_first_input_action_name(event: InputEvent) -> StringName:
  for action in InputMap.get_actions():
    if event.is_action(action):
      return action;

  return &'';


## Returns all [InputMap] actions associated with [param event].
## Returns an empty [Array] if no actions could be matched.
static func get_all_input_action_names(event: InputEvent) -> Array[StringName]:
  var matched_actions := [] as Array[StringName];

  for action in InputMap.get_actions():
    if event.is_action(action):
      matched_actions.append(action);

  return matched_actions;
