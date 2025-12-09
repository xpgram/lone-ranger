## A component to a GridEntity that manages a context action for player objects.
## This class is intended to be extended: by default, it defines no context action, it
## only provides the interface.
class_name ContextAction
extends Node


## Returns true if the given actor is capable of and allowed to perform this context
## action.
@warning_ignore('unused_parameter')
func can_interact(actor: GridEntity) -> bool:
  return false;


## Animates and ratifies the effects of the context action.
@warning_ignore('unused_parameter')
func perform_interaction_async(actor: GridEntity) -> void:
  pass
